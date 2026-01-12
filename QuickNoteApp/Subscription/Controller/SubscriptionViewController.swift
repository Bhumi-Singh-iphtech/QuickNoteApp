//
//  SubscriptionViewController.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 06/01/26.
//

import UIKit

class SubscriptionViewController: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startSubscriptionButton: UIButton!

    @IBAction func startSubscriptionTapped(_ sender: UIButton) {
        navigateToHome()
    }
    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let homeTabBar = storyboard.instantiateViewController(
            withIdentifier: "CustomTabBarController"
        ) as? CustomTabBarController else {
            return
        }

        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate {

            sceneDelegate.window?.rootViewController = homeTabBar
            sceneDelegate.window?.makeKeyAndVisible()
        }
        
    }


    // MARK: - Data Source
    private let features: [ProFeatureModel] = [
        ProFeatureModel(iconName: "folder", title: "200GB of Storage "),
        ProFeatureModel(iconName: "Search", title: "Advanced search"),
        ProFeatureModel(iconName: "icon", title: "Advanced export features"),
        ProFeatureModel(iconName: "sync", title: "Sync and backup"),
        ProFeatureModel(iconName: "Customer", title: "24/7 Chat Support")
    ]


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#232327")
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.2)
     

        tableView.showsVerticalScrollIndicator = false

        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDelegate
extension SubscriptionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UITableViewDataSource
extension SubscriptionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return features.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProFeatureTableViewCell",
            for: indexPath
        ) as? ProFeatureTableViewCell else {
            return UITableViewCell()
        }

        let feature = features[indexPath.row]
        cell.configure(iconName: feature.iconName, title: feature.title)

        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 20)
        return cell
    }
}
