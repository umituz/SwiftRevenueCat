import Foundation
import RevenueCat

extension SubscriptionStore {

    public func refreshStatus() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            applyCustomerInfo(info)
        } catch {
            getLogger().error("Failed to refresh status: \(error.localizedDescription)")
        }
        await fetchOfferings()
    }

    public func fetchOfferings() async {
        guard !isLoading else { return }
        setIsLoading(true)
        defer { setIsLoading(false) }

        if let fetched = await getOfferingsRepo().fetch() {
            setOfferings(fetched)
            updateDisplay()
        }
    }

    public func verifyProStatusForCriticalOperation() async -> Bool {
        guard ProStatusCache.load() else {
            getLogger().info("Pro status cache check failed - user not pro")
            return false
        }

        do {
            let info = try await Purchases.shared.customerInfo()
            let entitlement = EntitlementResolver.activeEntitlement(from: info)
            let isActuallyPro = entitlement != nil

            if isActuallyPro {
                ProStatusCache.save(isPro: true, expirationDate: entitlement?.expirationDate)
                applyCustomerInfo(info)
                getLogger().info("Pro status verified for critical operation")
            } else {
                ProStatusCache.save(isPro: false, expirationDate: nil)
                applyCustomerInfo(info)
                getLogger().warning("Pro status cache invalid - user not actually pro")
            }

            return isActuallyPro
        } catch {
            getLogger().error("Failed to verify pro status: \(error.localizedDescription)")
            return false
        }
    }

    public func isSubscriptionActive() -> Bool {
        guard let entitlement = EntitlementResolver.activeEntitlement(from: customerInfo) else {
            return false
        }
        if let expirationDate = entitlement.expirationDate {
            return Date() < expirationDate
        }
        return true
    }

    public func getExpirationDate() -> Date? {
        EntitlementResolver.activeEntitlement(from: customerInfo)?.expirationDate
    }
}
