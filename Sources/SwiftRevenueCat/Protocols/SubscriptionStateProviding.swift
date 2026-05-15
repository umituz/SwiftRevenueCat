import Foundation
import RevenueCat

@MainActor
public protocol SubscriptionStateProviding: AnyObject {
    var isPro: Bool { get }
    var isLoading: Bool { get }
    var offerings: Offerings? { get }
    var customerInfo: CustomerInfo? { get }
    var hasVerifiedWithServer: Bool { get }
}
