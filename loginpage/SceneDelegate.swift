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
        let token = UserDefaults.standard.string(forKey: "login_token")

        let rootVC: UIViewController

        if isLoggedIn, let token = token, !token.isEmpty {

            print("✅ User already logged in → Opening Groups")
            print("🔐 Token found:", token)

            // ✅ MUST open GrpViewController (groups screen)
            rootVC = storyboard.instantiateViewController(
                withIdentifier: "GrpViewController"
            )

        } else {

            print("❌ User not logged in or token missing → Opening Login")

            // 🧹 Clean invalid session
            UserDefaults.standard.removeObject(forKey: "login_token")
            UserDefaults.standard.set(false, forKey: "isLoggedIn")

            rootVC = storyboard.instantiateViewController(
                withIdentifier: "ViewController"
            )
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

