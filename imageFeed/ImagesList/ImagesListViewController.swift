import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    private var likeBlockingView: UIView?
    private var likeActivityIndicator: UIActivityIndicatorView?
    
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(imagesListDidChange),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        imagesListService.fetchPhotosNextPage()
    }
    
    @objc private func imagesListDidChange() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        let newCount = newPhotos.count
        let addedCount = newCount - oldCount
        
        guard addedCount > 0 else { return }
        
        photos = newPhotos
        
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == SegueIdentifiers.showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        let photo = photos[indexPath.row]
        if let fullURL = photo.fullImageURL {
            viewController.fullImageURL = fullURL
        }
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImageView.kf.setImage(with: url)
        }
        
        cell.cellImageView.layer.cornerRadius = 16
        cell.cellImageView.clipsToBounds = true
        cell.cellImageView.contentMode = .scaleAspectFill
        
        if let createdAt = photo.createdAt {
            cell.cellDateLabel.text = DateFormatter.dateFormatter.string(from: createdAt)
        } else {
            cell.cellDateLabel.text = "-"
        }
        
        setIsLiked(for: cell, isLiked: photo.isLiked)
    }
    
    private func setIsLiked(for cell: ImagesListCell, isLiked: Bool) {
        let imageName = isLiked ? "LikeButtonActive" : "LikeButtonNoActive"
        cell.cellLikeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    private func showLikeLoader() {
        guard likeBlockingView == nil else { return }

        let blockingView = UIView(frame: view.bounds)
        blockingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        blockingView.isUserInteractionEnabled = true
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = blockingView.center
        indicator.startAnimating()
        
        blockingView.addSubview(indicator)
        view.addSubview(blockingView)
        
        likeBlockingView = blockingView
        likeActivityIndicator = indicator
    }

    private func hideLikeLoader() {
        likeActivityIndicator?.stopAnimating()
        likeBlockingView?.removeFromSuperview()
        likeBlockingView = nil
        likeActivityIndicator = nil
    }

}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueIdentifiers.showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 2 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let newIsLike = !photo.isLiked
        
        showLikeLoader()

        imagesListService.changeLike(photoId: photo.id, isLike: newIsLike) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLikeLoader()
                guard let self = self else { return }
                
                switch result {
                case .success:
                    var updatedPhoto = photo
                    updatedPhoto.isLiked = newIsLike
                    self.photos[indexPath.row] = updatedPhoto
                    self.setIsLiked(for: cell, isLiked: newIsLike)
                case .failure(let error):
                    print("ImagesListViewController: Failed to change like: \(error)")
                }
            }
        }
    }
}
