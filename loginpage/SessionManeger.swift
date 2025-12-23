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

    static var isLoggedIn: Bool {
        return authToken != nil
    }

    static func logout() {
        UserDefaults.standard.removeObject(forKey: "login_token")
        UserDefaults.standard.removeObject(forKey: "loggedInPhone")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        
    }
}
