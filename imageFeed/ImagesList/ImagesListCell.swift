import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImageView: UIImageView!
    @IBOutlet var cellDateLabel: UILabel!
    @IBOutlet var cellLikeButton: UIButton!
}
