import UIKit

class CustomTabBarController: UITabBarController {
    
    private let customTabBar = CustomTabBarView()
    private let tabModels: [TabBarItemModel] = [
        TabBarItemModel(icon: "house", title: "Home"),
        TabBarItemModel(icon: "plus.app", title: "Add"),
        TabBarItemModel(icon: "magnifyingglass", title: "Search")
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        self.view.backgroundColor = UIColor(hex: "#2F2F34")
        
        // Hide system tab bar
        tabBar.isHidden = true
        
        setupCustomTabBar()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        self.view.backgroundColor = UIColor(hex: "#2F2F34")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
     
        view.bringSubviewToFront(customTabBar)
    }
    
    // MARK: - Public Tab Selection API
    func selectTab(index: Int) {
        guard index >= 0, index < (viewControllers?.count ?? 0) else { return }

        customTabBar.updateSelection(index: index)
        selectedIndex = index
    }

    // MARK: - Public Methods
    func setCustomTabBar(hidden: Bool) {
        customTabBar.isHidden = hidden
        tabBar.isHidden = hidden
    }
    
    // MARK: - Setup Methods
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
    
    
    private func createNavigationController(rootVC: UIViewController) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootVC)
        
      
        navController.view.backgroundColor = .systemBackground
        
    
        
        return navController
    }
}

// MARK: - CustomTabBarDelegate
extension CustomTabBarController: CustomTabBarDelegate {
    
    func didSelectTab(index: Int) {
           // Update custom tab bar selection
           customTabBar.updateSelection(index: index)
           
           // Smooth transition between tabs
           UIView.transition(with: self.view,
                            duration: 0.2,
                            options: .transitionCrossDissolve,
                            animations: {
                                self.selectedIndex = index
                            },
                            completion: nil)
       }

}

// MARK: - UITabBarControllerDelegate for smooth transitions
extension CustomTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                         animationControllerForTransitionFrom fromVC: UIViewController,
                         to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeTransitionAnimation()
    }
    
    // Update custom tab bar when system tab changes (if needed)
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item) else { return }
        customTabBar.updateSelection(index: index)
    }
}

// Custom fade transition animation
class FadeTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0
        
        UIView.animate(withDuration: 0.2, animations: {
            toViewController.view.alpha = 1
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
