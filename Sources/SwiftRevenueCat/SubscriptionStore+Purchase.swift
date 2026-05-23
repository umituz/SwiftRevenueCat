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
        setLoading(true)
        defer { setLoading(false) }

        let result = await executor.purchase(package)
        await refreshStatus()
        return result
    }

    public func restorePurchases() async -> RestoreResult {
        setLoading(true)
        defer { setLoading(false) }

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
