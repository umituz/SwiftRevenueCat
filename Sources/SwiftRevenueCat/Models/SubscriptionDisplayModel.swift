import Foundation

public struct SubscriptionDisplayModel: Equatable {
    public let isPro: Bool
    public let isLifetime: Bool
    public let planName: String
    public let priceText: String
    public let expirationDate: String?
    public let purchaseDate: String?
    public let storeName: String
    public let isSandbox: Bool
    public let willRenew: Bool

    public init(
        isPro: Bool,
        isLifetime: Bool,
        planName: String,
        priceText: String,
        expirationDate: String?,
        purchaseDate: String?,
        storeName: String,
        isSandbox: Bool,
        willRenew: Bool
    ) {
        self.isPro = isPro
        self.isLifetime = isLifetime
        self.planName = planName
        self.priceText = priceText
        self.expirationDate = expirationDate
        self.purchaseDate = purchaseDate
        self.storeName = storeName
        self.isSandbox = isSandbox
        self.willRenew = willRenew
    }

    public static let empty = SubscriptionDisplayModel(
        isPro: false,
        isLifetime: false,
        planName: "Free",
        priceText: "",
        expirationDate: nil,
        purchaseDate: nil,
        storeName: "",
        isSandbox: false,
        willRenew: false
    )
}
