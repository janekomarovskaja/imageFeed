
import XCTest
@testable import imageFeed

final class ImagesListViewTests: XCTestCase {

    // MARK: - Properties

    var presenter: ImagesListPresenterMock!
    var service: ImagesListServiceMock!
    var spy: ImageListViewControllerSpyMock!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        presenter = ImagesListPresenterMock()
        service = ImagesListServiceMock()
        spy = ImageListViewControllerSpyMock()
    }

    override func tearDown() {
        weak var weakPresenter = presenter
        weak var weakService = service
        weak var weakSpy = spy

        presenter = nil
        service = nil
        spy = nil
        super.tearDown()

        XCTAssertNil(weakPresenter)
        XCTAssertNil(weakService)
        XCTAssertNil(weakSpy)
    }

    // MARK: - Presenter tests

    func testPhotosCount() {
        // Then
        XCTAssertEqual(presenter.photosCount, 10)
    }

    func testViewDidLoad() {
        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testFetchNextPage() {
        // When
        presenter.fetchNextPage()

        // Then
        XCTAssertTrue(presenter.fetchNextPageCalled)
    }

    func testDidTapLike() {
        // Given
        let cell = ImagesListCell()

        // When
        presenter.didTapLike(on: cell)

        // Then
        XCTAssertTrue(presenter.didTapLikeCalledWithCell === cell)
    }

    func testPhotoAtIndex() {
        // When
        let photo = presenter.photo(at: 5)

        // Then
        XCTAssertEqual(presenter.photoCalledIndex, 5)
        XCTAssertEqual(photo.id, "1")
    }

    // MARK: - Service tests

    func testAddPhotoToArray() {
        // Given
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

        // When
        service.addPhoto(photo)

        // Then
        XCTAssertEqual(service.photos.count, 1)
        XCTAssertEqual(service.photos.first?.id, "1")
    }

    // MARK: - View (Spy) tests

    func testReloadTable() {
        // When
        spy.reloadTable()

        // Then
        XCTAssertTrue(spy.reloadTableCalled)
    }

    func testInsertRows() {
        // Given
        let indexPaths = [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)]

        // When
        spy.insertRows(at: indexPaths)

        // Then
        XCTAssertTrue(spy.insertRowsCalled)
        XCTAssertEqual(spy.insertRowsIndexPaths, indexPaths)
    }

    func testShowLikeLoader() {
        // When
        spy.showLikeLoader()

        // Then
        XCTAssertTrue(spy.showLikeLoaderCalled)
    }

    func testHideLikeLoader() {
        // When
        spy.hideLikeLoader()

        // Then
        XCTAssertTrue(spy.hideLikeLoaderCalled)
    }

    func testUpdateLikeState() {
        // Given
        let cell = ImagesListCell()
        let isLiked = true

        // When
        spy.updateLikeState(for: cell, isLiked: isLiked)

        // Then
        XCTAssertTrue(spy.updateLikeStateCalled)
        XCTAssertTrue(spy.updatedLikeStateCell === cell)
        XCTAssertEqual(spy.updatedLikeStateIsLiked, isLiked)
    }
}
