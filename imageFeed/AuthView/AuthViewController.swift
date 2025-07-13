import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    private let authScreenPicture = UIImageView()
    private let authButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: UIColors.ypBlack)
        setupPicture()
        setupAuthButton()
    }
    
    private func setupPicture() {
        authScreenPicture.image = UIImage(named: ImageNames.authScreenPictureName)
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
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        webView.delegate = self
        webView.modalPresentationStyle = .fullScreen
        webView.presenter = presenter
        presenter.view = webView

        present(webView, animated: true, completion: nil)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(code: code) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let token):
                OAuth2TokenStorage().token = token
                DispatchQueue.main.async {
                    self.delegate?.didAuthenticate(self)
                }
                print("Token received successfully")

            case .failure(let error):
                print("Some errors occurred while receiving the token: \(error)")
                self.showLoginErrorAlert()
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    private func showLoginErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "ОK", style: .default))
        present(alert, animated: true)
    }
}
