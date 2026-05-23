import Foundation

public struct SubscriptionStatus: Equatable, Sendable {
    public let isSubscribed: Bool
    public let expirationDate: Date?
    public let isActive: Bool

    public init(isSubscribed: Bool, expirationDate: Date?, isActive: Bool) {
        self.isSubscribed = isSubscribed
        self.expirationDate = expirationDate
        self.isActive = isActive
    }
}
