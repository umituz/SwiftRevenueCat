import Foundation
import RevenueCat
import StoreKit

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension SubscriptionStore {

    public func purchase(_ plan: Plan) async -> PurchaseResult {
        await purchase(plan.revenueCatPackage)
    }

    public func purchase(_ package: Package) async -> PurchaseResult {
        await purchase(package, entitlementRequired: true)
    }

    /// Purchase a consumable package (credits, coins, one-time packs).
    /// A completed, non-cancelled purchase is a success — consumables never
    /// grant an entitlement, so the entitlement check is skipped.
    public func purchaseConsumable(_ package: Package) async -> PurchaseResult {
        await purchase(package, entitlementRequired: false)
    }

    public func purchase(_ package: Package, entitlementRequired: Bool) async -> PurchaseResult {
        let result = await executor.purchase(package, entitlementRequired: entitlementRequired)
        await refreshStatus()
        return result
    }

    public func restorePurchases() async -> RestoreResult {
        let result = await executor.restorePurchases()
        await refreshStatus()
        return result
    }

    public func manageSubscription() {
        guard let url = config?.manageSubscriptionsURL else {
            logger.error("manageSubscriptionsURL is not configured")
            return
        }

        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #elseif canImport(AppKit)
        NSWorkspace.shared.open(url)
        #endif
    }

    public func presentCodeRedemptionSheet() {
        #if canImport(UIKit) && !os(visionOS)
        SKPaymentQueue.default().presentCodeRedemptionSheet()
        #endif
    }

    @discardableResult
    public func logIn(_ userId: String) async throws -> Bool {
        guard Purchases.isConfigured else {
            throw SubscriptionError.notConfigured
        }
        let (customerInfo, created) = try await Purchases.shared.logIn(userId)
        applyCustomerInfo(customerInfo)
        return created
    }

    public func logOut() async throws {
        guard Purchases.isConfigured else {
            throw SubscriptionError.notConfigured
        }
        let customerInfo = try await Purchases.shared.logOut()
        applyCustomerInfo(customerInfo)
    }
}
