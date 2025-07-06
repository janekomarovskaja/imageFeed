import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    var isLiked: Bool
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String?
    
    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
}
