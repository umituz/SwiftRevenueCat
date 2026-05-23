import Foundation
import RevenueCat

extension SubscriptionStore {

    public func refreshStatus() async {
        guard guardIsConfigured(#function) else { return }

        setLoading(true)
        defer { setLoading(false) }

        do {
            let info = try await Purchases.shared.customerInfo()
            applyCustomerInfo(info)
        } catch {
            logger.error("Failed to refresh status: \(error.localizedDescription)")
        }

        await performOfferingsFetch()
    }

    public func fetchOfferings() async {
        guard guardIsConfigured(#function) else { return }
        guard !isLoading else { return }
        setLoading(true)
        defer { setLoading(false) }

        await performOfferingsFetch()
    }

    func performOfferingsFetch() async {
        if let fetched = await offeringsRepo.fetch() {
            updateOfferings(fetched)
            updateDisplay()
        }
    }

    public func verifySubscriptionForCriticalOperation() async -> Bool {
        guard guardIsConfigured(#function) else { return false }

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
        guard guardIsConfigured(#function) else { return .unknown }
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
