import UIKit
import Kingfisher

protocol ProfileViewProtocol: AnyObject {
    func updateProfileDetails(profile: Profile)
    func updateAvatarImage(url: URL)
}

final class ProfileViewController: UIViewController, ProfileViewProtocol {

    var presenter: ProfileViewPresenterProtocol!

    private let userPicture = UIImageView()
    private let userName = UILabel()
    private let userNickname = UILabel()
    private let userDescription = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack

        setupUserPicture()
        setupuserName()
        setupUserNickname()
        setupUserDescription()
        setupExitButton()
        
        presenter.viewDidLoad()
    }
    
    func configure(presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
    }

    func updateProfileDetails(profile: Profile) {
        userName.text = profile.name
        userNickname.text = profile.loginName
        userDescription.text = profile.bio
    }

    func updateAvatarImage(url: URL) {
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
        userName.accessibilityLabel = "ProfileUserName"
        
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
        userNickname.accessibilityLabel = "ProfileUserNickName"

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
        userDescription.accessibilityLabel = "ProfileDescription"

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
        exitButton.accessibilityIdentifier = "ExitButton"
    }

    @objc private func didTapButton(_ sender: UIButton) {
        showLogoutAlert()
    }

    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.presenter.logout()
            self.dismiss(animated: true)
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Unable to get main window")
                return
            }
            window.rootViewController = SplashViewController()
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}
