import Foundation
import RevenueCat
import OSLog

enum SubscriptionContentResolver {

    private static let logger = Logger(subsystem: "SwiftRevenueCat", category: "SubscriptionContentResolver")

    private static let periodFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .weekOfMonth, .month, .year]
        formatter.unitsStyle = .full
        return formatter
    }()

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    static func activePlanDisplayName(
        customerInfo: CustomerInfo?,
        offerings: Offerings?,
        entitlementId: String? = nil
    ) -> String {
        guard let info = customerInfo else { return "" }

        let activeProductId = resolveActiveProductId(from: info, entitlementId: entitlementId)
        guard let productId = activeProductId else { return "" }

        let matchingPackage = offerings?.current?.availablePackages
            .first(where: { $0.storeProduct.productIdentifier == productId })

        if let pkg = matchingPackage {
            return pkg.storeProduct.localizedTitle
        }
        return productId
    }

    static func activePlanPriceText(
        customerInfo: CustomerInfo?,
        offerings: Offerings?,
        entitlementId: String? = nil
    ) -> String {
        guard let info = customerInfo else { return "" }

        let activeProductId = resolveActiveProductId(from: info, entitlementId: entitlementId)
        guard let productId = activeProductId else { return "" }

        let matchingPackage = offerings?.current?.availablePackages
            .first(where: { $0.storeProduct.productIdentifier == productId })

        if let pkg = matchingPackage {
            let price = pkg.storeProduct.localizedPriceString
            let period = periodLabel(from: pkg.storeProduct)
            return "\(price) \(period)"
        }

        return ""
    }

    static func periodLabel(from product: StoreProduct) -> String {
        guard let period = product.subscriptionPeriod else {
            return SubscriptionL10n.once
        }
        let formatted = formatPeriod(period)
        return "/\(formatted)"
    }

    static func formatPeriod(_ period: SubscriptionPeriod) -> String {
        let components = PeriodConverter.toDateComponents(period)
        return periodFormatter.string(from: components) ?? ""
    }

    static func buildOfferDescription(
        discount: StoreProductDiscount,
        regularPrice: String
    ) -> String? {
        let period = discount.subscriptionPeriod
        let periodText = formatPeriod(period)

        switch discount.paymentMode {
        case .freeTrial:
            return SubscriptionL10n.freeTrialOffer(
                trialPeriod: periodText,
                price: regularPrice
            )
        case .payUpFront, .payAsYouGo:
            return SubscriptionL10n.introOffer(
                introPrice: discount.localizedPriceString,
                introPeriod: periodText,
                regularPrice: regularPrice
            )
        @unknown default:
            return nil
        }
    }

    static func relativeDateString(from date: Date) -> String {
        relativeDateFormatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Private

    private static func resolveActiveProductId(
        from info: CustomerInfo,
        entitlementId: String? = nil
    ) -> String? {
        if let entitlement = EntitlementResolver.activeEntitlement(
            from: info,
            entitlementId: entitlementId
        ) {
            return entitlement.productIdentifier
        }
        return info.activeSubscriptions.first
    }
}
