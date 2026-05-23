import Foundation

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

    public init(
        isSubscribed: Bool,
        isLifetime: Bool,
        planName: String,
        priceText: String,
        expirationDate: String?,
        purchaseDate: String?,
        storeName: String,
        willRenew: Bool,
        isInBillingRetryPeriod: Bool = false
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
            willRenew: false
        )
    }
}
