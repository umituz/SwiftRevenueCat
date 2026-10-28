import Foundation
import RevenueCat

@MainActor
public protocol PurchaseProviding: AnyObject {
    /// Purchase a RevenueCat package.
    ///
    /// - Parameter package: The package to purchase.
    /// - Parameter entitlementRequired: When `true` (default), the result is
    ///   `.success` only if the purchase also granted an active entitlement —
    ///   the right semantics for subscriptions. Pass `false` for consumables
    ///   (coins, credits, one-time packs): a completed, non-cancelled purchase
    ///   is a success even though no entitlement is ever granted.
    func purchase(_ package: Package, entitlementRequired: Bool) async -> PurchaseResult
    func restorePurchases() async -> RestoreResult
}

extension PurchaseProviding {
    /// Subscription purchase — success requires an active entitlement.
    public func purchase(_ package: Package) async -> PurchaseResult {
        await purchase(package, entitlementRequired: true)
    }
}
