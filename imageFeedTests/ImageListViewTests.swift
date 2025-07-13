import XCTest
@testable import imageFeed

final class ImagesListViewTests: XCTestCase {
    func testPhotosCount() {
        let presenterSpy = ImageListPresenterSpy()
        
        XCTAssertEqual(presenterSpy.photosCount, 10)
    }
    
    func testViewDidLoad() {
        let presenterSpy = ImageListPresenterSpy()
        
        presenterSpy.viewDidLoad()
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testFetchNextPage() {
        let presenterSpy = ImageListPresenterSpy()
        
        presenterSpy.fetchNextPage()
        
        XCTAssertTrue(presenterSpy.fetchNextPageCalled)
    }
    
    func testDidTapLike() {
        let presenterSpy = ImageListPresenterSpy()
        let cell = ImagesListCell()
        
        presenterSpy.didTapLike(on: cell)
        
        XCTAssertTrue(presenterSpy.didTapLikeCalledWithCell === cell)
    }
    
    func testPhotoAtIndex() {
        let presenterSpy = ImageListPresenterSpy()
        
        let photo = presenterSpy.photo(at: 5)
        
        XCTAssertEqual(presenterSpy.photoCalledIndex, 5)
        XCTAssertEqual(photo.id, "1")
    }
    
    func testAddPhotoToArray() {
        let service = MockImagesListService()
        XCTAssertTrue(service.photos.isEmpty)
        
        let photo = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            isLiked: false,
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            fullImageURL: "https://example.com/full.jpg"
        )
        
        service.addPhoto(photo)
        
        XCTAssertEqual(service.photos.count, 1)
        XCTAssertEqual(service.photos.first?.id, "1")
    }
    
    func testReloadTable() {
        let spy = ImageListViewControllerSpy()
        
        spy.reloadTable()
        
        XCTAssertTrue(spy.reloadTableCalled)
    }

    func testInsertRows() {
        let spy = ImageListViewControllerSpy()
        let indexPaths = [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)]
        
        spy.insertRows(at: indexPaths)
        
        XCTAssertTrue(spy.insertRowsCalled)
        XCTAssertEqual(spy.insertRowsIndexPaths, indexPaths)
    }

    func testShowLikeLoader() {
        let spy = ImageListViewControllerSpy()
        
        spy.showLikeLoader()
        
        XCTAssertTrue(spy.showLikeLoaderCalled)
    }

    func testHideLikeLoader() {
        let spy = ImageListViewControllerSpy()
        
        spy.hideLikeLoader()
        
        XCTAssertTrue(spy.hideLikeLoaderCalled)
    }

    func testUpdateLikeState() {
        let spy = ImageListViewControllerSpy()
        let cell = ImagesListCell()
        let isLiked = true
        
        spy.updateLikeState(for: cell, isLiked: isLiked)
        
        XCTAssertTrue(spy.updateLikeStateCalled)
        XCTAssertTrue(spy.updatedLikeStateCell === cell)
        XCTAssertEqual(spy.updatedLikeStateIsLiked, isLiked)
    }
}
