import UIKit

final class ProfileViewController: UIViewController {
    let exitButtonPictureName = "exitButton"
    let userPictureName = "userPic"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userPicture = UIImage(named: userPictureName)
        let imageView = UIImageView(image: userPicture)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 61
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
                
        let userName = UILabel()
        userName.text = "Екатерина Новикова"
        userName.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        userName.textColor = .ypWhite
        userName.numberOfLines = 0
        userName.lineBreakMode = .byWordWrapping
        userName.sizeToFit()
        userName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userName)
        userName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        userName.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        userName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        let userNickname = UILabel()
        userNickname.text = "@ekaterina_nov"
        userNickname.textColor = .ypGray
        userNickname.font = UIFont.systemFont(ofSize: 13)
        userNickname.numberOfLines = 0
        userNickname.lineBreakMode = .byWordWrapping
        userNickname.sizeToFit()
        userNickname.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userNickname)
        userNickname.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        userNickname.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        userNickname.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8).isActive = true
        
        let userDescription = UILabel()
        userDescription.text = "Hello, world!"
        userDescription.textColor = .ypWhite
        userDescription.font = UIFont.systemFont(ofSize: 13)
        userDescription.numberOfLines = 0
        userDescription.lineBreakMode = .byWordWrapping
        userDescription.sizeToFit()
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userDescription)
        userDescription.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        userDescription.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        userDescription.topAnchor.constraint(equalTo: userNickname.bottomAnchor, constant: 8).isActive = true
        
        let exitButton = UIButton.systemButton(
            with: UIImage(named: exitButtonPictureName)!,
                    target: self,
                    action: #selector(Self.didTapButton)
                )
        exitButton.tintColor = .ypRed
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
            
    }
    
    @objc private func didTapButton(_ sender: UIButton) {}
}
