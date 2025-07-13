@testable import imageFeed
import Foundation

final class ImageListPresenterSpy: ImagesListPresenterProtocol {
    var photosCount: Int = 10
    
    var photoCalledIndex: Int?
    var viewDidLoadCalled = false
    var fetchNextPageCalled = false
    var didTapLikeCalledWithCell: ImagesListCell?

    func photo(at index: Int) -> Photo {
        photoCalledIndex = index
        return Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            isLiked: false,
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            fullImageURL: "https://example.com/full.jpg"
        )
    }

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func fetchNextPage() {
        fetchNextPageCalled = true
    }

    func didTapLike(on cell: ImagesListCell) {
        didTapLikeCalledWithCell = cell
    }
}

final class MockImagesListService {
    var photos: [Photo] = []
    func addPhoto(_ photo: Photo) {
        photos.append(photo)
    }
}
