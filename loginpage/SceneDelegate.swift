//
//  SceneDelegate.swift
//  loginpage
//
//  Created by Apple on 08/10/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            // Check if user is logged in
            let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            
            if isLoggedIn {
                // User is logged in — navigate to HomeVC directly
                let homeVC = storyboard.instantiateViewController(withIdentifier: "GrpViewController") as! GrpViewController
                let navController = UINavigationController(rootViewController: homeVC)
                navController.overrideUserInterfaceStyle = .light
                window.rootViewController = navController
            } else {
                // User not logged in — show login screen
                let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                let navController = UINavigationController(rootViewController: loginVC)
                navController.overrideUserInterfaceStyle = .light
                window.rootViewController = navController
            }

            // Force Light Mode globally
            window.overrideUserInterfaceStyle = .light
            window.backgroundColor = .white // Ensures white background
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    // Other default scene methods unchanged...
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

