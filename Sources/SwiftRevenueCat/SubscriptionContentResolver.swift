import Foundation
import RevenueCat
import OSLog

enum SubscriptionContentResolver {

    private static let logger = Logger(subsystem: "SwiftRevenueCat", category: "SubscriptionContentResolver")

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

        let count = period.value
        if count == 1 {
            switch period.unit {
            case .day:   return SubscriptionL10n.perDay
            case .week:  return SubscriptionL10n.perWeek
            case .month: return SubscriptionL10n.perMonth
            case .year:  return SubscriptionL10n.perYear
            @unknown default: return ""
            }
        } else {
            switch period.unit {
            case .day:   return SubscriptionL10n.perDays(count)
            case .week:  return SubscriptionL10n.perWeeks(count)
            case .month: return SubscriptionL10n.perMonths(count)
            case .year:  return SubscriptionL10n.perYears(count)
            @unknown default: return ""
            }
        }
    }

    static func formatPeriod(_ period: SubscriptionPeriod) -> String {
        let count = period.value
        if count == 1 {
            switch period.unit {
            case .day:   return SubscriptionL10n.oneDay
            case .week:  return SubscriptionL10n.oneWeek
            case .month: return SubscriptionL10n.oneMonth
            case .year:  return SubscriptionL10n.oneYear
            @unknown default: return ""
            }
        } else {
            switch period.unit {
            case .day:   return SubscriptionL10n.days(count)
            case .week:  return SubscriptionL10n.weeks(count)
            case .month: return SubscriptionL10n.months(count)
            case .year:  return SubscriptionL10n.years(count)
            @unknown default: return ""
            }
        }
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
        guard let weeklyProduct = allProducts.first(where: { product in
            if let period = product.subscriptionPeriod,
               period.unit == .week, period.value == 1 {
                return true
            }
            return false
        }) else {
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
}
