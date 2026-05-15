import Foundation
import RevenueCat
import OSLog

enum SubscriptionContentResolver {

    private static let logger = Logger(subsystem: "SwiftRevenueCat", category: "SubscriptionContentResolver")

    static func activePlanDisplayName(customerInfo: CustomerInfo?, offerings: Offerings?) -> String {
        guard let info = customerInfo else { return "" }

        let activeProductId: String?
        if let entitlement = EntitlementResolver.activeEntitlement(from: info) {
            activeProductId = entitlement.productIdentifier
        } else {
            activeProductId = info.activeSubscriptions.first
        }

        guard let productId = activeProductId else { return "" }

        let matchingPackage = offerings?.current?.availablePackages
            .first(where: { $0.storeProduct.productIdentifier == productId })

        if let pkg = matchingPackage {
            return pkg.storeProduct.localizedTitle
        }
        return productId
    }

    static func activePlanPriceText(customerInfo: CustomerInfo?, offerings: Offerings?) -> String {
        guard let info = customerInfo else { return "" }

        let activeProductId: String?
        if let entitlement = EntitlementResolver.activeEntitlement(from: info) {
            activeProductId = entitlement.productIdentifier
        } else {
            activeProductId = info.activeSubscriptions.first
        }

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

    static func savingsPercentage(annualProduct: StoreProduct, allProducts: [StoreProduct]) -> String? {
        guard let weeklyProduct = allProducts.first(where: { product in
            if let period = product.subscriptionPeriod, period.unit == .week, period.value == 1 {
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
}
