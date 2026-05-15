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

    static func activePlanDisplayName(
        customerInfo: CustomerInfo?,
        offerings: Offerings?
    ) -> String {
        guard let info = customerInfo else { return "" }

        let activeProductId = resolveActiveProductId(from: info)

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
        offerings: Offerings?
    ) -> String {
        guard let info = customerInfo else { return "" }

        let activeProductId = resolveActiveProductId(from: info)

        guard let productId = activeProductId else { return "" }

        let matchingPackage = offerings?.current?.availablePackages
            .first(where: { $0.storeProduct.productIdentifier == productId })

        if let pkg = matchingPackage {
            let price = pkg.storeProduct.localizedPriceString
            let period = periodLabel(from: pkg.storeProduct)
            return "\(price)\(period)"
        }

        return ""
    }

    static func periodLabel(from product: StoreProduct) -> String {
        guard let period = product.subscriptionPeriod else {
            return SubscriptionL10n.once
        }
        let formatted = formatPeriod(period)
        return "/ \(formatted)"
    }

    static func formatPeriod(_ period: SubscriptionPeriod) -> String {
        let components = periodToDateComponents(period)
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

    static func savingsPercentage(
        annualProduct: StoreProduct,
        allProducts: [StoreProduct]
    ) -> String? {
        guard let weeklyProduct = allProducts.first(where: productIsWeekly) else {
            return nil
        }

        let annualPerWeek = annualProduct.price / 52.0
        let weeklyPrice = weeklyProduct.price
        guard weeklyPrice > 0 else { return nil }

        let savings = ((weeklyPrice - annualPerWeek) / weeklyPrice) * 100.0
        let rounded = Int(truncating: (savings as NSDecimalNumber).rounding(accordingToBehavior: nil))
        guard rounded > 0 else { return nil }
        return SubscriptionL10n.savings(rounded)
    }

    static func relativeDateString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Private

    private static func resolveActiveProductId(from info: CustomerInfo) -> String? {
        if let entitlement = EntitlementResolver.activeEntitlement(from: info) {
            return entitlement.productIdentifier
        }
        return info.activeSubscriptions.first
    }

    private static func productIsWeekly(_ product: StoreProduct) -> Bool {
        guard let period = product.subscriptionPeriod,
              period.unit == .week, period.value == 1 else {
            return false
        }
        return true
    }

    private static func periodToDateComponents(_ period: SubscriptionPeriod) -> DateComponents {
        switch period.unit {
        case .day:   return DateComponents(day: period.value)
        case .week:  return DateComponents(weekOfMonth: period.value)
        case .month: return DateComponents(month: period.value)
        case .year:  return DateComponents(year: period.value)
        @unknown default: return DateComponents()
        }
    }
}
