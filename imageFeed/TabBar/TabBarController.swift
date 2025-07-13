import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            fatalError("ImagesListViewController not found")
        }

        let imagesListPresenter = ImagesListPresenter(view: imagesListViewController)
        imagesListViewController.configure(presenter: imagesListPresenter)

        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileViewPresenter(view: profileViewController)
        profileViewController.configure(presenter: profilePresenter)
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
