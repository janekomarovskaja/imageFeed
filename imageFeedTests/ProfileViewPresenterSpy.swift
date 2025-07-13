@testable import imageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var didLoad = false
    var didLogout = false

    var view: ProfileViewProtocol?

    func viewDidLoad() {
        didLoad = true
    }

    func logout() {
        didLogout = true
    }
}
