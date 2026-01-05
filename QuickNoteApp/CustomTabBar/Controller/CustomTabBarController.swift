import UIKit

class CustomTabBarController: UITabBarController {

    private let customTabBar = CustomTabBarView()

    private let tabModels: [TabBarItemModel] = [
        TabBarItemModel(icon: "house", title: "Home"),
        TabBarItemModel(icon: "plus.app", title: "Add"),
        TabBarItemModel(icon: "magnifyingglass", title: "Search")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.isHidden = true
        setupCustomTabBar()
//        setupViewControllers()
    }

    private func setupCustomTabBar() {
        view.addSubview(customTabBar)
        customTabBar.delegate = self
        customTabBar.configure(with: tabModels)

        customTabBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            customTabBar.heightAnchor.constraint(equalToConstant: 90)
        ])
    }

//    private func setupViewControllers() {
//        viewControllers = [
//            HomeViewController(),
//            UIViewController(), // Record
//            UIViewController()  // Profile
//        ]
//    }
}

extension CustomTabBarController: CustomTabBarDelegate {
    func didSelectTab(index: Int) {
        selectedIndex = index
    }
}
