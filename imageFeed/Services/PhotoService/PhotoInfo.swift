import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    var isLiked: Bool
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String?
}
