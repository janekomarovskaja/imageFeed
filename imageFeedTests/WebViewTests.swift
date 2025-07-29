import XCTest
@testable import imageFeed

final class WebViewTests: XCTestCase {

    // MARK: - Properties

    var presenterSpy: WebViewPresenterSpyMock!
    var viewSpy: WebViewViewControllerSpyMock!
    var authHelper: AuthHelper!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        presenterSpy = WebViewPresenterSpyMock()
        viewSpy = WebViewViewControllerSpyMock()
        authHelper = AuthHelper()
    }

    override func tearDown() {
        weak var weakPresenter = presenterSpy
        weak var weakViewSpy = viewSpy
        weak var weakAuthHelper = authHelper

        presenterSpy = nil
        viewSpy = nil
        authHelper = nil

        super.tearDown()

        XCTAssertNil(weakPresenter)
        XCTAssertNil(weakViewSpy)
        XCTAssertNil(weakAuthHelper)
    }

    // MARK: - ViewController → Presenter

    func testViewControllerCallsViewDidLoad() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController

        // When
        _ = viewController.view // triggers viewDidLoad

        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    // MARK: - Presenter → View

    func testPresenterCallsLoadRequestOnViewDidLoad() {
        // Given
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewSpy.presenter = presenter
        presenter.view = viewSpy

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(viewSpy.loadRequestCalled)
    }

    func testProgressIsVisibleWhenLessThanOne() {
        // Given
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6

        // When
        let shouldHide = presenter.shouldHideProgress(for: progress)

        // Then
        XCTAssertFalse(shouldHide)
    }

    func testProgressIsHiddenWhenOne() {
        // Given
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0

        // When
        let shouldHide = presenter.shouldHideProgress(for: progress)

        // Then
        XCTAssertTrue(shouldHide)
    }

    // MARK: - AuthHelper

    func testAuthHelperGeneratesCorrectAuthURL() {
        // Given
        let configuration = AuthConfiguration.standard
        let helper = AuthHelper(configuration: configuration)

        // When
        guard let url = helper.authURL() else {
            XCTFail("authURL is nil")
            return
        }

        let urlString = url.absoluteString

        // Then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }

    func testAuthHelperExtractsCodeFromURL() {
        // Given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let helper = AuthHelper()

        // When
        let code = helper.code(from: url)

        // Then
        XCTAssertEqual(code, "test code")
    }
}
