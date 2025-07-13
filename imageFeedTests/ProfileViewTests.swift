import XCTest
@testable import imageFeed

final class ProfileViewTests: XCTestCase {
    func testPresenterViewDidLoad() {
        let presenterSpy = ProfileViewPresenterSpy()
        let sut = ProfileViewController()
        sut.presenter = presenterSpy

        sut.viewDidLoad()

        XCTAssertTrue(presenterSpy.didLoad)
    }

    func testPresenterLogout() {
        let presenterSpy = ProfileViewPresenterSpy()
        let sut = ProfileViewController()
        sut.presenter = presenterSpy

        sut.presenter.logout()

        XCTAssertTrue(presenterSpy.didLogout)
    }
    
    func testUpdateProfileDetails() {
        let spy = ProfileViewControllerSpy()
        let profile = Profile(
            username: "testuser",
            name: "Test User",
            loginName: "@test",
            bio: "Hello World"
        )

        spy.updateProfileDetails(profile: profile)

        XCTAssertTrue(spy.updateProfileDetailsCalled)
        XCTAssertEqual(spy.updatedProfile?.username, profile.username)
        XCTAssertEqual(spy.updatedProfile?.name, profile.name)
        XCTAssertEqual(spy.updatedProfile?.loginName, profile.loginName)
        XCTAssertEqual(spy.updatedProfile?.bio, profile.bio)
    }

    func testUpdateAvatarImage() {
        let spy = ProfileViewControllerSpy()
        let url = URL(string: "https://example.com/avatar.jpg")!

        spy.updateAvatarImage(url: url)

        XCTAssertTrue(spy.updateAvatarImageCalled)
        XCTAssertEqual(spy.updatedAvatarURL, url)
    }
}
