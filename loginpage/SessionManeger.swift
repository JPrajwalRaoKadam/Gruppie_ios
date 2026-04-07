//
//  SessionManeger.swift
//  loginpage
//
//  Created by apple on 23/12/25.
//

import UIKit

struct SessionManager {

    static var authToken: String? {
        return UserDefaults.standard.string(forKey: "login_token")
    }

    static var useRoleToken: String? {
        return UserDefaults.standard.string(forKey: "user_role_Token")
    }
    
    static var role_name: String? {
            return UserDefaults.standard.string(forKey: "role_name")
    }
    
    static var isLoggedIn: Bool {
        return authToken != nil
    }

    static func logout() {

        print("🚪 Logging out – clearing session")

        let defaults = UserDefaults.standard

        // 🔐 Auth
        defaults.removeObject(forKey: "login_token")
        defaults.removeObject(forKey: "groups_token")
        defaults.set(false, forKey: "isLoggedIn")

        // 📱 User data
        defaults.removeObject(forKey: "loggedInPhone")

        defaults.synchronize()
    }
    
    static func removeUserRoleToken() {
        UserDefaults.standard.removeObject(forKey: "user_role_Token")
    }
}
