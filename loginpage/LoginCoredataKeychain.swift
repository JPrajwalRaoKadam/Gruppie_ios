//
//  LoginCoredataKeychain.swift
//  loginpage
//
//  Created by apple on 17/03/25.
//

import UIKit
import CoreData
import Security


class KeychainHelper {
    static let shared = KeychainHelper()

    private init() {}

    func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data
        ] as [String: Any]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func retrieve(service: String, account: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as [String: Any]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        return nil
    }
}

class CoreDataHelper {
    static let shared = CoreDataHelper()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func saveUser(phone: String, password: String) {
        let user = User(context: context)
        user.phone = phone
        user.password = password
        do {
            try context.save()
        } catch {
            print("Failed to save user: \(error)")
        }
    }

    func fetchUser(phone: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "phone == %@", phone)
        do {
            let users = try context.fetch(request)
            return users.first
        } catch {
            print("Failed to fetch user: \(error)")
            return nil
        }
    }
}


