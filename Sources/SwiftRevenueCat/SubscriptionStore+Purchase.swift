import Foundation
import RevenueCat
import StoreKit

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension SubscriptionStore {

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
        let urlString = config?.manageSubscriptionsURL
            ?? "https://apps.apple.com/account/subscriptions"
        guard let url = URL(string: urlString) else { return }

        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #elseif canImport(AppKit)
        NSWorkspace.shared.open(url)
        #endif
    }

    public func presentCodeRedemptionSheet() {
        #if canImport(UIKit)
        AppStore.presentCodeRedemptionSheet()
        #endif
    }

    @discardableResult
    public func logIn(_ userId: String) async throws -> Bool {
        let (customerInfo, created) = try await Purchases.shared.logIn(userId)
        applyCustomerInfo(customerInfo)
        return created
    }

    public func logOut() async {
        do {
            let customerInfo = try await Purchases.shared.logOut()
            applyCustomerInfo(customerInfo)
        } catch {
            logger.error("RevenueCat logout failed: \(error.localizedDescription)")
            reset()
        }
    }
}
