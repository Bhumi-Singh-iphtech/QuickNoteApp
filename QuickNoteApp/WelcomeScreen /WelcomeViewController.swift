//
//  WelocomeViewController.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 05/01/26.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBAction func letsStartTapped(_ sender: UIButton) {
        navigateToSubscription()
    }


    private func navigateToSubscription() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let subscriptionVC = storyboard.instantiateViewController(
            withIdentifier: "SubscriptionViewController"
        )

        subscriptionVC.modalPresentationStyle = .fullScreen

        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate {

            sceneDelegate.window?.rootViewController = subscriptionVC
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }

    }

