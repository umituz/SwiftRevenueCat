import Foundation
import OSLog
import Security

enum ProStatusCache {

    private struct CacheEntry: Codable {
        let isPro: Bool
        let expirationDate: Date?
        let lastVerifiedAt: Date
    }

    private static var cacheKey: String = "pro_status_cache"
    private static let logger = Logger(subsystem: "SwiftRevenueCat", category: "ProStatusCache")

    static func configure(cacheKey: String) {
        Self.cacheKey = cacheKey
    }

    static func save(isPro: Bool, expirationDate: Date? = nil) {
        let entry = CacheEntry(
            isPro: isPro,
            expirationDate: expirationDate,
            lastVerifiedAt: Date()
        )
        do {
            let data = try JSONEncoder().encode(entry)
            saveToKeychain(data: data)
        } catch {
            logger.error("Failed to encode cache entry: \(error.localizedDescription)")
        }
    }

    static func load() -> Bool {
        guard let data = loadFromKeychain() else { return false }
        do {
            let entry = try JSONDecoder().decode(CacheEntry.self, from: data)
            guard entry.isPro else { return false }
            if let expiration = entry.expirationDate {
                return Date() < expiration
            }
            return true
        } catch {
            logger.error("Failed to decode cache entry: \(error.localizedDescription)")
            return false
        }
    }

    static func needsReverification() -> Bool {
        guard let data = loadFromKeychain() else { return true }
        do {
            let entry = try JSONDecoder().decode(CacheEntry.self, from: data)
            guard entry.isPro else { return true }
            if let expiration = entry.expirationDate {
                return Date() >= expiration
            }
            return false
        } catch {
            return true
        }
    }

    static func getExpirationDate() -> Date? {
        guard let data = loadFromKeychain() else { return nil }
        do {
            let entry = try JSONDecoder().decode(CacheEntry.self, from: data)
            return entry.expirationDate
        } catch {
            return nil
        }
    }

    static func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: cacheKey
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            logger.error("Keychain clear failed with OSStatus: \(status)")
        }
    }

    // MARK: - Private Keychain Operations

    private static func saveToKeychain(data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: cacheKey,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let updateAttributes: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            if addStatus != errSecSuccess {
                logger.error("Keychain save failed with OSStatus: \(addStatus)")
            }
        } else if updateStatus != errSecSuccess {
            logger.error("Keychain update failed with OSStatus: \(updateStatus)")
        }
    }

    private static func loadFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: cacheKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status != errSecSuccess && status != errSecItemNotFound {
            logger.error("Keychain load failed with OSStatus: \(status)")
        }
        return status == errSecSuccess ? (result as? Data) : nil
    }
}
