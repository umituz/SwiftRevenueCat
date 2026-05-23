import Foundation
import RevenueCat

extension SubscriptionStore {

    public func refreshStatus() async {
        guard Purchases.isConfigured else {
            logger.warning("Purchases is not configured yet. Skipping refreshStatus.")
            return
        }
        do {
            let info = try await Purchases.shared.customerInfo()
            applyCustomerInfo(info)
        } catch {
            logger.error("Failed to refresh status: \(error.localizedDescription)")
        }
        await fetchOfferings()
    }

    public func fetchOfferings() async {
        guard Purchases.isConfigured else {
            logger.warning("Purchases is not configured yet. Skipping fetchOfferings.")
            return
        }
        guard !isLoading else { return }
        setLoading(true)
        defer { setLoading(false) }

        if let fetched = await offeringsRepo.fetch() {
            updateOfferings(fetched)
            updateDisplay()
        }
    }

    public func verifySubscriptionForCriticalOperation() async -> Bool {
        guard Purchases.isConfigured else {
            logger.warning("Purchases is not configured yet. Skipping subscription verification.")
            return false
        }

        do {
            let info = try await Purchases.shared.customerInfo()
            let entitlement = EntitlementResolver.activeEntitlement(
                from: info,
                entitlementId: config?.entitlementId
            )
            let isSubscribed = entitlement != nil

            SubscriptionCache.save(
                isSubscribed: isSubscribed,
                expirationDate: entitlement?.expirationDate
            )

            if isSubscribed {
                logger.info("Subscription verified for critical operation")
            } else {
                logger.warning("No active subscription found for critical operation")
            }

            applyCustomerInfo(info)
            return isSubscribed
        } catch {
            logger.error("Failed to verify subscription: \(error.localizedDescription)")
            return false
        }
    }

    public func isSubscriptionActive() -> Bool {
        EntitlementResolver.hasActiveEntitlement(
            from: customerInfo,
            entitlementId: config?.entitlementId
        )
    }

    public func getExpirationDate() -> Date? {
        EntitlementResolver.activeEntitlement(
            from: customerInfo,
            entitlementId: config?.entitlementId
        )?.expirationDate
    }

    public func checkTrialEligibility(
        for productId: String
    ) async -> TrialEligibility {
        guard Purchases.isConfigured else {
            logger.warning("Purchases is not configured yet. Skipping checkTrialEligibility.")
            return .unknown
        }
        guard let product = offerings?.current?.availablePackages
            .first(where: { $0.storeProduct.productIdentifier == productId })?
            .storeProduct else {
            return .unknown
        }

        let status = await Purchases.shared.checkTrialOrIntroDiscountEligibility(
            product: product
        )

        switch status {
        case .eligible: return .eligible
        case .ineligible: return .ineligible
        case .unknown: return .unknown
        case .noIntroOfferExists: return .noOfferAvailable
        @unknown default: return .unknown
        }
    }
}
