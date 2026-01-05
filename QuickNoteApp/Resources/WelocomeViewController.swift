//
//  WelocomeViewController.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 05/01/26.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBAction func letsStartTapped(_ sender: UIButton) {
        navigateToHome()
    }

    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeTabBar = storyboard.instantiateViewController(
            withIdentifier: "CustomTabBarController"
        ) as! CustomTabBarController

        // Replace root view controller
        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate {

            sceneDelegate.window?.rootViewController = homeTabBar
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
}
