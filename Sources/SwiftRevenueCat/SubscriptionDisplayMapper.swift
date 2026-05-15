import Foundation
import RevenueCat
import OSLog

enum SubscriptionDisplayMapper {

    private static let logger = Logger(subsystem: "SwiftRevenueCat", category: "SubscriptionDisplayMapper")

    @MainActor
    static func map(customerInfo: CustomerInfo?, offerings: Offerings?) -> SubscriptionDisplayModel {
        guard let info = customerInfo else { return .empty }

        let entitlement = EntitlementResolver.activeEntitlement(from: info)
        let proActive = entitlement != nil
        let isLifetime = proActive && entitlement?.expirationDate == nil

        return SubscriptionDisplayModel(
            isPro: proActive,
            isLifetime: isLifetime,
            planName: SubscriptionContentResolver.activePlanDisplayName(customerInfo: info, offerings: offerings),
            priceText: SubscriptionContentResolver.activePlanPriceText(customerInfo: info, offerings: offerings),
            expirationDate: entitlement.flatMap { $0.expirationDate.map { formatDate($0) } },
            purchaseDate: entitlement.flatMap { $0.latestPurchaseDate.map { formatDate($0) } },
            storeName: mapStore(entitlement?.store),
            isSandbox: entitlement?.isSandbox ?? false,
            willRenew: isLifetime ? false : (entitlement?.willRenew ?? false)
        )
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private static func mapStore(_ store: Store?) -> String {
        guard let store else { return "" }
        switch store {
        case .appStore: return "App Store"
        case .macAppStore: return "Mac App Store"
        case .playStore: return "Play Store"
        case .stripe: return "Web"
        case .promotional: return "Promotional"
        default: return ""
        }
    }
}
