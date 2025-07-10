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
        
        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        let navController: UINavigationController
        
        if isLoggedIn {
            let homeVC = storyboard.instantiateViewController(withIdentifier: "GrpViewController") as! GrpViewController
            navController = UINavigationController(rootViewController: homeVC)
        } else {
            let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            navController = UINavigationController(rootViewController: loginVC)
        }
        
        // Force light mode
        navController.overrideUserInterfaceStyle = .light
        window.overrideUserInterfaceStyle = .light
        
        // Fix for top spacing issue: set nav bar not translucent
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.backgroundColor = .white
        
        window.rootViewController = navController
        window.backgroundColor = .white
        self.window = window
        window.makeKeyAndVisible()
        
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

