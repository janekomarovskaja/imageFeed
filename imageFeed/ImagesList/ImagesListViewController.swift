import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let currentDate = Date()
    private let likeButtonActiveImage = "LikeButtonActive"
    private let likeButtonNoActiveImage = "LikeButtonNoActive"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {


        let imageName = "\(indexPath.row)"
        guard let image = UIImage(named: imageName) else {
            return
        }
        cell.cellImageView.layer.cornerRadius = 16
        cell.cellImageView.clipsToBounds = true
        cell.cellImageView.contentMode = .scaleAspectFill
        cell.cellImageView.image = image
        
        cell.cellDateLabel.text = DateFormatter.dateFormatter.string(from: currentDate)
        let isLiked = indexPath.row % 2 == 0
        let heartImageName = isLiked ? likeButtonActiveImage : likeButtonNoActiveImage

        cell.cellLikeButton.setImage(UIImage(named: heartImageName), for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    // TO DO: func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
