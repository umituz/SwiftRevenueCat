import Foundation
import OSLog
import CryptoKit

enum SubscriptionCache {

    private struct CacheEntry: Codable {
        let isSubscribed: Bool
        let expirationDate: Date?
        let lastVerifiedAt: Date
    }

    private struct SealedCacheEntry: Codable {
        let payload: Data
        let hash: String
    }

    private static let logger = Logger(subsystem: SwiftRevenueCatConstants.subsystem, category: "SubscriptionCache")

    private static let synchronizationQueue = DispatchQueue(
        label: "\(SwiftRevenueCatConstants.subsystem).SubscriptionCache"
    )
    private static var _cacheKey: String = "subscription_status_cache"

    private static var cacheKey: String {
        synchronizationQueue.sync { _cacheKey }
    }

    static func configure(cacheKey: String) {
        synchronizationQueue.sync { _cacheKey = cacheKey }
    }

    static func save(isSubscribed: Bool, expirationDate: Date? = nil) {
        let entry = CacheEntry(
            isSubscribed: isSubscribed,
            expirationDate: expirationDate,
            lastVerifiedAt: Date()
        )
        do {
            let payload = try JSONEncoder().encode(entry)
            let hash = computeHash(for: payload)
            let sealed = SealedCacheEntry(payload: payload, hash: hash)
            let data = try JSONEncoder().encode(sealed)
            KeychainStore.save(data: data, forAccount: cacheKey)
        } catch {
            logger.error("Failed to encode cache entry: \(error.localizedDescription)")
        }
    }

    static func loadSubscribedStatus() -> Bool {
        guard let entry = loadEntry() else { return false }
        guard entry.isSubscribed else { return false }
        if let expiration = entry.expirationDate {
            return Date() < expiration
        }
        return true
    }

    static func needsReverification() -> Bool {
        guard let entry = loadEntry() else { return true }
        guard entry.isSubscribed else { return true }
        if let expiration = entry.expirationDate {
            return Date() >= expiration
        }
        return false
    }

    static func getExpirationDate() -> Date? {
        guard let entry = loadEntry() else { return nil }
        return entry.expirationDate
    }

    static func clear() {
        KeychainStore.delete(account: cacheKey)
    }

    static func resetCacheKey() {
        synchronizationQueue.sync { _cacheKey = "subscription_status_cache" }
    }

    // MARK: - Entry Loading with Integrity Verification

    private static func loadEntry() -> CacheEntry? {
        guard let data = KeychainStore.load(account: cacheKey) else { return nil }
        do {
            let sealed = try JSONDecoder().decode(SealedCacheEntry.self, from: data)
            guard verifyHash(for: sealed.payload, expected: sealed.hash) else {
                logger.error("Cache integrity check failed — possible tampering. Clearing cache.")
                clear()
                return nil
            }
            return try JSONDecoder().decode(CacheEntry.self, from: sealed.payload)
        } catch {
            logger.error("Cache entry corrupted, clearing: \(error.localizedDescription)")
            clear()
            return nil
        }
    }

    // MARK: - Integrity

    private static func computeHash(for data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    private static func verifyHash(for data: Data, expected: String) -> Bool {
        computeHash(for: data) == expected
    }
}
