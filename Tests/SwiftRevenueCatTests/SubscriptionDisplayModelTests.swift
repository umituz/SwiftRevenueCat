import Testing
import Foundation
@testable import SwiftRevenueCat

// MARK: - SubscriptionPeriodKind

@Suite("SubscriptionPeriodKind")
struct SubscriptionPeriodKindTests {

    @Test("classifies monthly product identifiers")
    func monthlyFromIdentifier() {
        #expect(SubscriptionPeriodKind.from(productIdentifier: "com.example.app.premium_monthly") == .monthly)
        #expect(SubscriptionPeriodKind.from(productIdentifier: "app.pro.MONTH1") == .monthly)
    }

    @Test("classifies yearly product identifiers")
    func yearlyFromIdentifier() {
        #expect(SubscriptionPeriodKind.from(productIdentifier: "com.example.app.premium_yearly") == .yearly)
        #expect(SubscriptionPeriodKind.from(productIdentifier: "com.example.app.premium_annual") == .yearly)
    }

    @Test("unrecognized identifiers classify as none")
    func noneFromIdentifier() {
        #expect(SubscriptionPeriodKind.from(productIdentifier: "com.example.app.credits_100") == .none)
        #expect(SubscriptionPeriodKind.from(productIdentifier: "com.example.app.lifetime") == .none)
    }
}

// MARK: - SubscriptionStatusKind

@Suite("SubscriptionStatusKind")
struct SubscriptionStatusKindTests {

    @Test("active kinds grant access")
    func activeKinds() {
        #expect(SubscriptionStatusKind.active.isActive)
        #expect(SubscriptionStatusKind.willExpire.isActive)
    }

    @Test("inactive kinds deny access")
    func inactiveKinds() {
        #expect(!SubscriptionStatusKind.unknown.isActive)
        #expect(!SubscriptionStatusKind.notSubscribed.isActive)
        #expect(!SubscriptionStatusKind.expired.isActive)
        #expect(!SubscriptionStatusKind.canceled.isActive)
    }

    @Test("status text is never empty")
    func statusTextNotEmpty() {
        for kind in [SubscriptionStatusKind.unknown, .notSubscribed, .active, .willExpire, .expired, .canceled] {
            #expect(!kind.statusText.isEmpty)
        }
    }
}

// MARK: - SubscriptionDisplayModel (expiry lifecycle)

@Suite("SubscriptionDisplayModel lifecycle")
struct SubscriptionDisplayModelLifecycleTests {

    @Test("expired when expiration date is in the past")
    func isExpired() {
        let model = SubscriptionDisplayModel(
            isSubscribed: true, isLifetime: false, planName: "Pro", priceText: "$9.99",
            expirationDate: nil, purchaseDate: nil, storeName: "App Store",
            willRenew: false, expiresAt: Date().addingTimeInterval(-60)
        )
        #expect(model.isExpired)
        #expect(model.daysUntilExpiry == nil)
    }

    @Test("days until expiry counts whole days")
    func daysUntilExpiry() {
        // +60s margin so the second Date() inside the model can't shave a day off.
        let model = SubscriptionDisplayModel(
            isSubscribed: true, isLifetime: false, planName: "Pro", priceText: "$9.99",
            expirationDate: nil, purchaseDate: nil, storeName: "App Store",
            willRenew: true, expiresAt: Date().addingTimeInterval(3 * 86_400 + 60)
        )
        #expect(!model.isExpired)
        #expect(model.daysUntilExpiry == 3)
    }

    @Test("lifetime plans have no expiry math")
    func lifetime() {
        let model = SubscriptionDisplayModel(
            isSubscribed: true, isLifetime: true, planName: "Pro", priceText: "$99.99",
            expirationDate: nil, purchaseDate: nil, storeName: "App Store",
            willRenew: false, expiresAt: nil
        )
        #expect(!model.isExpired)
        #expect(model.daysUntilExpiry == nil)
    }
}
