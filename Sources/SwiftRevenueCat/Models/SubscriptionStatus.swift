import Foundation

public struct SubscriptionStatus {
    public let isPro: Bool
    public let expirationDate: Date?
    public let isActive: Bool

    public init(isPro: Bool, expirationDate: Date?, isActive: Bool) {
        self.isPro = isPro
        self.expirationDate = expirationDate
        self.isActive = isActive
    }
}
