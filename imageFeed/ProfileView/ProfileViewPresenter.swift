import UIKit

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func logout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    init(view: ProfileViewProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(profileImageDidChange),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )

        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
            fetchAvatarURL(username: profile.username)
        } else if let token = tokenStorage.token {
            ProfileService.shared.fetchProfile(token) { [weak self] result in
                switch result {
                case .success(let profile):
                    self?.view?.updateProfileDetails(profile: profile)
                    self?.fetchAvatarURL(username: profile.username)
                case .failure(let error):
                    print("ProfilePresenter: Failed to fetch profile - \(error)")
                }
            }
        }
    }

    private func fetchAvatarURL(username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            switch result {
            case .success(let urlString):
                guard let url = URL(string: urlString) else {
                    print("ProfilePresenter: Invalid URL string: \(urlString)")
                    return
                }
                self?.view?.updateAvatarImage(url: url)
            case .failure(let error):
                print("ProfilePresenter: Failed to fetch avatar URL - \(error)")
            }
        }
    }
    
    @objc private func profileImageDidChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let urlString = userInfo[ProfileImageService.userInfoKey] as? String,
            let url = URL(string: urlString)
        else {
            print("ProfilePresenter: Invalid avatar URL in notification")
            return
        }
        view?.updateAvatarImage(url: url)
    }
    
    func logout() {
        ProfileLogoutService.shared.logout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
