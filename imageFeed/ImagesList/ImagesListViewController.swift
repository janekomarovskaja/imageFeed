import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func reloadTable()
    func insertRows(at indexPaths: [IndexPath])
    func showLikeLoader()
    func hideLikeLoader()
    func updateLikeState(for cell: ImagesListCell, isLiked: Bool)
}

final class ImagesListViewController: UIViewController, ImagesListViewProtocol {
    
    @IBOutlet private var tableView: UITableView!
    private var likeBlockingView: UIView?
    private var likeActivityIndicator: UIActivityIndicatorView?
    
    private var presenter: ImagesListPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        presenter = ImagesListPresenter(view: self)
        presenter.viewDidLoad()
    }
    
    func configure(presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func showLikeLoader() {
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
    
    func hideLikeLoader() {
        likeActivityIndicator?.stopAnimating()
        likeBlockingView?.removeFromSuperview()
        likeBlockingView = nil
        likeActivityIndicator = nil
    }
    
    func updateLikeState(for cell: ImagesListCell, isLiked: Bool) {
        let imageName = isLiked ? "LikeButtonActive" : "LikeButtonNoActive"
        cell.cellLikeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = presenter.photo(at: indexPath.row)
        
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
        
        updateLikeState(for: cell, isLiked: photo.isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueIdentifiers.showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath.row)
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photosCount
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
            presenter.fetchNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        presenter.didTapLike(on: cell)
    }
}
