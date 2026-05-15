import Foundation
import RevenueCat
#if canImport(UIKit)
import UIKit
#endif

extension SubscriptionStore {

    public func purchase(_ package: Package) async -> PurchaseResult {
        setIsLoading(true)
        defer { setIsLoading(false) }

        let result = await getExecutor().purchase(package)
        await refreshStatus()
        return result
    }

    public func restorePurchases() async -> RestoreResult {
        setIsLoading(true)
        defer { setIsLoading(false) }

        let result = await getExecutor().restorePurchases()
        await refreshStatus()
        return result
    }

    public func manageSubscription() {
        let urlString = getConfig()?.manageSubscriptionsURL ?? "https://apps.apple.com/account/subscriptions"
        guard let url = URL(string: urlString) else { return }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }
}
