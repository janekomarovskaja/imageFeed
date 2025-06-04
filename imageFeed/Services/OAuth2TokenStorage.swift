import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "bearerToken"
    private let userDefaults = UserDefaults.standard

    var token: String? {
        get {
            userDefaults.string(forKey: tokenKey)
        }
        set {
            userDefaults.set(newValue, forKey: tokenKey)
        }
    }
}

