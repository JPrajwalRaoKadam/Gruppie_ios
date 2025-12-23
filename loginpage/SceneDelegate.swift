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

        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")

        let rootVC: UIViewController

        if isLoggedIn {
            rootVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") 
            print("✅ User already logged in → Opening Groups")
        } else {
            rootVC = storyboard.instantiateViewController(withIdentifier: "ViewController")
            print("❌ User not logged in → Opening Login")
        }

        let nav = UINavigationController(rootViewController: rootVC)
        nav.navigationBar.isHidden = true

        window?.rootViewController = nav
        window?.makeKeyAndVisible()
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

