import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    private let imageFeedScreen = ImagesListViewController()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let token = self.storage.token {
                self.switchToTabBarController()
            } else {
                self.showAuthScreen()
            }
        }
    }
    
    private func showAuthScreen() {
        let authScreen = AuthViewController()
        authScreen.delegate = self

        let navController = UINavigationController(rootViewController: authScreen)
        navController.modalPresentationStyle = .fullScreen

        present(navController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) {
            self.switchToTabBarController()
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        window.rootViewController = tabBarController
    }
}

