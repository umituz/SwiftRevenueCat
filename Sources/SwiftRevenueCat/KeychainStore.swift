import Foundation
import OSLog
import Security

enum KeychainStore {

    private static let logger = Logger(subsystem: SwiftRevenueCatConstants.subsystem, category: "KeychainStore")
    private static let serviceIdentifier = SwiftRevenueCatConstants.subsystem

    @discardableResult
    static func save(data: Data, forAccount account: String) -> Bool {
        let deleteQuery = keychainQuery(account: account)
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status != errSecSuccess {
            logger.error("Keychain save failed with OSStatus: \(status)")
            return false
        }
        return true
    }

    static func load(account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status != errSecSuccess && status != errSecItemNotFound {
            logger.error("Keychain load failed with OSStatus: \(status)")
        }
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    static func delete(account: String) {
        let query = keychainQuery(account: account)
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            logger.error("Keychain delete failed with OSStatus: \(status)")
        }
    }

    private static func keychainQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: account
        ]
    }
}
