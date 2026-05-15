import Foundation
import RevenueCat
import OSLog

public enum SubscriptionContentResolver {

    private static let logger = Logger(subsystem: "SwiftRevenueCat", category: "SubscriptionContentResolver")

    public static func activePlanDisplayName(customerInfo: CustomerInfo?, offerings: Offerings?) -> String {
        guard let info = customerInfo else { return "" }

        if let activeSub = info.activeSubscriptions.first {
            if let pkg = offerings?.current?.availablePackages.first(where: { $0.storeProduct.productIdentifier == activeSub }) {
                return pkg.storeProduct.localizedTitle
            }
            return activeSub
        }

        if let entitlement = EntitlementResolver.activeEntitlement(from: info) {
            if let pkg = offerings?.current?.availablePackages.first(where: { $0.storeProduct.productIdentifier == entitlement.productIdentifier }) {
                return pkg.storeProduct.localizedTitle
            }
            return entitlement.productIdentifier
        }

        return ""
    }

    public static func activePlanPriceText(customerInfo: CustomerInfo?, offerings: Offerings?) -> String {
        guard let info = customerInfo else { return "" }

        if let activeSub = info.activeSubscriptions.first,
           let pkg = offerings?.current?.availablePackages.first(where: { $0.storeProduct.productIdentifier == activeSub }) {
            let price = pkg.storeProduct.localizedPriceString
            let period = periodLabel(from: pkg.storeProduct)
            return "\(price)\(period)"
        }

        if let entitlement = EntitlementResolver.activeEntitlement(from: info),
           let pkg = offerings?.current?.availablePackages.first(where: { $0.storeProduct.productIdentifier == entitlement.productIdentifier }) {
            return pkg.storeProduct.localizedPriceString
        }

        return ""
    }

    public static func periodLabel(from product: StoreProduct) -> String {
        guard let period = product.subscriptionPeriod else {
            return "once"
        }

        let count = period.value
        if count == 1 {
            switch period.unit {
            case .day:   return "/ day"
            case .week:  return "/ week"
            case .month: return "/ month"
            case .year:  return "/ year"
            @unknown default: return ""
            }
        } else {
            switch period.unit {
            case .day:   return "/ \(count) days"
            case .week:  return "/ \(count) weeks"
            case .month: return "/ \(count) months"
            case .year:  return "/ \(count) years"
            @unknown default: return ""
            }
        }
    }

    public static func savingsPercentage(annualProduct: StoreProduct, allProducts: [StoreProduct]) -> String? {
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
        let rounded = Int((savings as NSDecimalNumber).rounding(accordingToBehavior: nil).doubleValue)
        guard rounded > 0 else { return nil }
        return "SAVE \(rounded)%"
    }
}
