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

    /// The package for a product identifier, from the current (or first
    /// available) offering. Exposes the underlying RevenueCat package for
    /// consumers that need StoreKit-level details.
    public func package(matching productIdentifier: String) -> Package? {
        currentOffering()?.availablePackages.first {
            $0.storeProduct.productIdentifier == productIdentifier
        }
    }

    /// Localized price string (e.g. "$9.99") for a product identifier,
    /// or nil when the store isn't offering that product.
    public func localizedPrice(forProductIdentifier productIdentifier: String) -> String? {
        package(matching: productIdentifier)?.localizedPriceString
    }

    /// Current offering, falling back to the first available offering when
    /// none is marked current — no hardcoded offering identifiers.
    public func currentOffering() -> Offering? {
        guard let offerings else { return nil }
        if let current = offerings.current { return current }
        return offerings.all.values
            .sorted { $0.identifier < $1.identifier }
            .first
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
