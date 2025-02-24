import Foundation

class TokenManager {
    static let shared = TokenManager()  // Singleton instance

    private let tokenKey = "authToken"  // Key for storing the token

    private init() {}

    // Get the stored token
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }

    // Save a new token
    func setToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    // Remove the token
    func removeToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
