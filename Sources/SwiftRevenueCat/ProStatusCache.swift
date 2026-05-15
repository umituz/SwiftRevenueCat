import Foundation
import os
import Security

public enum ProStatusCache {

    private struct CacheEntry: Codable {
        let isPro: Bool
        let expirationDate: Date?
        let lastVerifiedAt: Date
    }

    private static var cacheKey: String = "pro_status_cache"

    public static func configure(cacheKey: String) {
        Self.cacheKey = cacheKey
    }

    public static func save(isPro: Bool, expirationDate: Date? = nil) {
        let entry = CacheEntry(
            isPro: isPro,
            expirationDate: expirationDate,
            lastVerifiedAt: Date()
        )
        do {
            let data = try JSONEncoder().encode(entry)
            saveToKeychain(data: data)
        } catch {
            Logger(subsystem: "SwiftRevenueCat", category: "ProStatusCache")
                .error("Failed to encode cache entry: \(error.localizedDescription)")
        }
    }

    public static func load() -> Bool {
        guard let data = loadFromKeychain() else { return false }
        let entry: CacheEntry
        do {
            entry = try JSONDecoder().decode(CacheEntry.self, from: data)
        } catch {
            Logger(subsystem: "SwiftRevenueCat", category: "ProStatusCache")
                .error("Failed to decode cache entry: \(error.localizedDescription)")
            return false
        }

        guard entry.isPro else { return false }

        if let expiration = entry.expirationDate {
            return Date() < expiration
        }

        return true
    }

    public static func needsReverification() -> Bool {
        guard let data = loadFromKeychain() else { return true }
        let entry: CacheEntry
        do {
            entry = try JSONDecoder().decode(CacheEntry.self, from: data)
        } catch {
            return true
        }

        guard entry.isPro else { return true }

        if let expiration = entry.expirationDate {
            return Date() >= expiration
        }

        return false
    }

    public static func getExpirationDate() -> Date? {
        guard let data = loadFromKeychain() else { return nil }
        let entry: CacheEntry
        do {
            entry = try JSONDecoder().decode(CacheEntry.self, from: data)
            return entry.expirationDate
        } catch {
            return nil
        }
    }

    // MARK: - Private Keychain Operations

    private static func saveToKeychain(data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: cacheKey,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)

        var addQuery = query
        addQuery[kSecValueData as String] = data
        SecItemAdd(addQuery as CFDictionary, nil)
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
        return status == errSecSuccess ? (result as? Data) : nil
    }
}
