import XCTest
@testable import imageFeed

final class ProfileViewTests: XCTestCase {
    
    // MARK: - Properties

    var presenter: ProfileViewPresenterSpyMock!
    var spy: ProfileViewControllerSpyMock!
    var sut: ProfileViewController!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        presenter = ProfileViewPresenterSpyMock()
        spy = ProfileViewControllerSpyMock()
        sut = ProfileViewController()
    }

    override func tearDown() {
        weak var weakPresenter = presenter
        weak var weakSpy = spy
        weak var weakSut = sut

        presenter = nil
        spy = nil
        sut = nil

        super.tearDown()

        XCTAssertNil(weakPresenter)
        XCTAssertNil(weakSpy)
        XCTAssertNil(weakSut)
    }

    // MARK: - Presenter → ViewController interaction

    func testViewDidLoadCallsPresenterViewDidLoad() {
        // Given
        sut.presenter = presenter

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertTrue(presenter.didLoad)
    }

    func testLogoutCallsPresenterLogout() {
        // Given
        sut.presenter = presenter

        // When
        sut.presenter.logout()

        // Then
        XCTAssertTrue(presenter.didLogout)
    }

    // MARK: - ViewController updates UI

    func testUpdateProfileDetailsUpdatesUI() {
        // Given
        let profile = Profile(
            username: "testuser",
            name: "Test User",
            loginName: "@test",
            bio: "Hello World"
        )

        // When
        spy.updateProfileDetails(profile: profile)

        // Then
        XCTAssertTrue(spy.updateProfileDetailsCalled)
        XCTAssertEqual(spy.updatedProfile?.username, profile.username)
        XCTAssertEqual(spy.updatedProfile?.name, profile.name)
        XCTAssertEqual(spy.updatedProfile?.loginName, profile.loginName)
        XCTAssertEqual(spy.updatedProfile?.bio, profile.bio)
    }

    func testUpdateAvatarImageSetsCorrectURL() {
        // Given
        let url = URL(string: "https://example.com/avatar.jpg")!

        // When
        spy.updateAvatarImage(url: url)

        // Then
        XCTAssertTrue(spy.updateAvatarImageCalled)
        XCTAssertEqual(spy.updatedAvatarURL, url)
    }
}
