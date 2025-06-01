import UIKit

final class AuthViewController: UIViewController {
    private let authScreenPictureName = "authScreenPicture"
    
    private let authScreenPicture = UIImageView()
    private let authButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicture()
        setupAuthButton()
    }
    
    private func setupPicture() {
        authScreenPicture.image = UIImage(named: authScreenPictureName)
        authScreenPicture.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(authScreenPicture)
        
        NSLayoutConstraint.activate([
            authScreenPicture.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authScreenPicture.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            authScreenPicture.widthAnchor.constraint(equalToConstant: 60),
            authScreenPicture.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupAuthButton() {
        authButton.layer.cornerRadius = 16
        authButton.layer.masksToBounds = true
        authButton.backgroundColor = .ypWhite
        authButton.translatesAutoresizingMaskIntoConstraints = false
        authButton.setTitle("Войти", for: .normal)
        authButton.setTitleColor(.ypBlack, for: .normal)
        authButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        view.addSubview(authButton)
        view.bringSubviewToFront(authButton)
        authButton.isUserInteractionEnabled = true
        authButton.isEnabled = true
        
        authButton.addTarget(self, action: #selector(authButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            authButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            authButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            authButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -124),
            authButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc private func authButtonTapped(_ sender: UIButton) {
        let webView = WebViewViewController()
        webView.delegate = self
        webView.modalPresentationStyle = .fullScreen
        present(webView, animated: true, completion: nil)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
