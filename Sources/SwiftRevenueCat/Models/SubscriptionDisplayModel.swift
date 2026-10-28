import Foundation

/// Everything a subscription settings screen needs, derived from
/// RevenueCat state — bind this directly to your UI.
public struct SubscriptionDisplayModel: Equatable, Sendable {
    public let isSubscribed: Bool
    public let isLifetime: Bool
    public let planName: String
    public let priceText: String
    public let expirationDate: String?
    public let purchaseDate: String?
    public let storeName: String
    public let willRenew: Bool
    public let isInBillingRetryPeriod: Bool

    /// Lifecycle state (active / willExpire / expired / …).
    public let statusKind: SubscriptionStatusKind
    /// Billing period of the active product (monthly / yearly / none).
    public let periodKind: SubscriptionPeriodKind
    /// Raw expiration date, for app-side date math and countdowns.
    public let expiresAt: Date?
    /// Product identifier of the active entitlement, if any.
    public let productIdentifier: String?

    public init(
        isSubscribed: Bool,
        isLifetime: Bool,
        planName: String,
        priceText: String,
        expirationDate: String?,
        purchaseDate: String?,
        storeName: String,
        willRenew: Bool,
        isInBillingRetryPeriod: Bool = false,
        statusKind: SubscriptionStatusKind = .unknown,
        periodKind: SubscriptionPeriodKind = .none,
        expiresAt: Date? = nil,
        productIdentifier: String? = nil
    ) {
        self.isSubscribed = isSubscribed
        self.isLifetime = isLifetime
        self.planName = planName
        self.priceText = priceText
        self.expirationDate = expirationDate
        self.purchaseDate = purchaseDate
        self.storeName = storeName
        self.willRenew = willRenew
        self.isInBillingRetryPeriod = isInBillingRetryPeriod
        self.statusKind = statusKind
        self.periodKind = periodKind
        self.expiresAt = expiresAt
        self.productIdentifier = productIdentifier
    }

    public static var empty: SubscriptionDisplayModel {
        SubscriptionDisplayModel(
            isSubscribed: false,
            isLifetime: false,
            planName: SubscriptionL10n.freeTier,
            priceText: "",
            expirationDate: nil,
            purchaseDate: nil,
            storeName: "",
            willRenew: false,
            statusKind: .notSubscribed
        )
    }

    /// True when the entitlement's expiration date is in the past.
    public var isExpired: Bool {
        guard let expiresAt else { return false }
        return expiresAt < Date()
    }

    /// Whole days until expiry; nil for lifetime or already-expired plans.
    public var daysUntilExpiry: Int? {
        guard let expiresAt, expiresAt > Date() else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day
    }
}
