import Foundation
import RevenueCat

extension SubscriptionStore {

    public func refreshStatus() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            applyCustomerInfo(info)
        } catch {
            logger.error("Failed to refresh status: \(error.localizedDescription)")
        }
        await fetchOfferings()
    }

    public func fetchOfferings() async {
        guard !isLoading else { return }
        setLoading(true)
        defer { setLoading(false) }

        if let fetched = await offeringsRepo.fetch() {
            updateOfferings(fetched)
            updateDisplay()
        }
    }

    public func verifyProStatusForCriticalOperation() async -> Bool {
        guard ProStatusCache.load() else {
            logger.info("Pro status cache check failed - user not pro")
            return false
        }

        do {
            let info = try await Purchases.shared.customerInfo()
            let entitlement = EntitlementResolver.activeEntitlement(
                from: info,
                entitlementId: config?.entitlementId
            )
            let isActuallyPro = entitlement != nil

            if isActuallyPro {
                ProStatusCache.save(isPro: true, expirationDate: entitlement?.expirationDate)
                applyCustomerInfo(info)
                logger.info("Pro status verified for critical operation")
            } else {
                ProStatusCache.save(isPro: false, expirationDate: nil)
                applyCustomerInfo(info)
                logger.warning("Pro status cache invalid - user not actually pro")
            }

            return isActuallyPro
        } catch {
            logger.error("Failed to verify pro status: \(error.localizedDescription)")
            return false
        }
    }

    public func isSubscriptionActive() -> Bool {
        let entitlement = EntitlementResolver.activeEntitlement(
            from: customerInfo,
            entitlementId: config?.entitlementId
        )
        guard let entitlement else { return false }
        if let expirationDate = entitlement.expirationDate {
            return Date() < expirationDate
        }
        return true
    }

    public func getExpirationDate() -> Date? {
        EntitlementResolver.activeEntitlement(
            from: customerInfo,
            entitlementId: config?.entitlementId
        )?.expirationDate
    }
}
