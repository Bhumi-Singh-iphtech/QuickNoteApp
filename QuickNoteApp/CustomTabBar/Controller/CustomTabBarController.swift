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
        
        // CRITICAL: Set tab bar controller's view background
        self.view.backgroundColor = .systemBackground
        
        // Hide system tab bar
        tabBar.isHidden = true
        
        setupCustomTabBar()
//        setupViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure background is consistently set
        self.view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Bring custom tab bar to front
        view.bringSubviewToFront(customTabBar)
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
    
//    private func setupViewControllers() {
////        let storyboard = UIStoryboard(name: "Main", bundle: nil)
////        
////        // Home Screen
////        let homeVC = storyboard.instantiateViewController(
////            withIdentifier: "HomeViewController"
////        ) as! HomeViewController
////        
////        // Add Note Screen
////        let addVC = storyboard.instantiateViewController(
////            withIdentifier: "AddNoteViewController"
////        ) as! AddNoteViewController
////        
//////        // Search Screen
//////        let searchVC = storyboard.instantiateViewController(
//////            withIdentifier: "SearchViewController"
//////        ) as! SearchViewController
//////        
////        // Create navigation controllers with proper background
////        let homeNav = createNavigationController(rootVC: homeVC)
////        let addNav = createNavigationController(rootVC: addVC)
//////        let searchNav = createNavigationController(rootVC: searchVC)
////        
////        // Hide system navigation bars
////        homeNav.setNavigationBarHidden(true, animated: false)
////        addNav.setNavigationBarHidden(true, animated: false)
//////        searchNav.setNavigationBarHidden(true, animated: false)
//////        
//////        // Set view controllers
//////        viewControllers = [homeNav, addNav, searchNav]
//////        selectedIndex = 0
//////        
////        // IMPORTANT: Update custom tab bar selection to match
//        customTabBar.updateSelection(index: 0)
//        
//        // Set delegate for smooth transitions
////        delegate = self
////    }
    
    private func createNavigationController(rootVC: UIViewController) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootVC)
        
        // CRITICAL: Set navigation controller's background
        navController.view.backgroundColor = .systemBackground
        
        // Additional iOS 15+ fixes
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
        }
        
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
