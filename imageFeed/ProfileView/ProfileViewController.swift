import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let userPicture = UIImageView()
    private let userName = UILabel()
    private let userNickname = UILabel()
    private let userDescription = UILabel()
    private let profileService = ProfileService()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack

        setupUserPicture()
        setupuserName()
        setupUserNickname()
        setupUserDescription()
        setupExitButton()
        setupAvatarObserver()

        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
            fetchAvatarURL(username: profile.username)
        } else if let token = OAuth2TokenStorage().token {
            ProfileService.shared.fetchProfile(token) { [weak self] result in
                switch result {
                case .success(let profile):
                    self?.updateProfileDetails(profile: profile)
                    self?.fetchAvatarURL(username: profile.username)
                case .failure(let error):
                    print("ProfileViewController: Failed to fetch profile - \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateProfileDetails(profile: Profile) {
        userName.text = profile.name
        userNickname.text = profile.loginName
        userDescription.text = profile.bio
    }

    private func fetchAvatarURL(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print("ProfileViewController: Failed to fetch avatar URL - \(error.localizedDescription)")
            }
        }
    }

    private func setupAvatarObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatarImage(_:)),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }

    @objc private func updateAvatarImage(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let urlString = userInfo[ProfileImageService.userInfoKey] as? String,
            let url = URL(string: urlString)
        else {
            print("ProfileViewController: Invalid avatar URL in notification")
            return
        }

        userPicture.kf.setImage(with: url)
    }

    private func setupUserPicture() {
        userPicture.image = UIImage(named: ImageNames.profileUserPictureName)
        userPicture.translatesAutoresizingMaskIntoConstraints = false
        userPicture.layer.cornerRadius = 35
        userPicture.clipsToBounds = true
        view.addSubview(userPicture)
        
        NSLayoutConstraint.activate([
            userPicture.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userPicture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            userPicture.widthAnchor.constraint(equalToConstant: 70),
            userPicture.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupuserName() {
        userName.text = "Екатерина Новикова"
        userName.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        userName.textColor = .ypWhite
        userName.numberOfLines = 0
        userName.lineBreakMode = .byWordWrapping
        userName.sizeToFit()
        userName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userName)
        
        NSLayoutConstraint.activate([
            userName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            userName.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            userName.topAnchor.constraint(equalTo: userPicture.bottomAnchor, constant: 8)
        ])
    }

    private func setupUserNickname() {
        userNickname.textColor = .ypGray
        userNickname.font = UIFont.systemFont(ofSize: 13)
        userNickname.numberOfLines = 0
        userNickname.lineBreakMode = .byWordWrapping
        userNickname.sizeToFit()
        userNickname.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userNickname)

        NSLayoutConstraint.activate([
            userNickname.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            userNickname.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            userNickname.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8)
        ])
    }

    private func setupUserDescription() {
        userDescription.text = "Hello, world!"
        userDescription.textColor = .ypWhite
        userDescription.font = UIFont.systemFont(ofSize: 13)
        userDescription.numberOfLines = 0
        userDescription.lineBreakMode = .byWordWrapping
        userDescription.sizeToFit()
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userDescription)

        NSLayoutConstraint.activate([
            userDescription.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            userDescription.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            userDescription.topAnchor.constraint(equalTo: userNickname.bottomAnchor, constant: 8)
        ])
    }

    private func setupExitButton() {
        guard let exitImage = UIImage(named: ImageNames.profileExitButtonPictureName) else {
            return
        }
        let exitButton = UIButton.systemButton(
            with: exitImage,
            target: self,
            action: #selector(Self.didTapButton)
        )
        exitButton.tintColor = .ypRed
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)

        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            exitButton.centerYAnchor.constraint(equalTo: userPicture.centerYAnchor)
        ])
    }

    @objc private func didTapButton(_ sender: UIButton) {
        OAuth2TokenStorage().token = nil

        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Unable to get main window")
            return
        }

        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
