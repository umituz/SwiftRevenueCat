import Foundation
import RevenueCat
import OSLog

enum SubscriptionDisplayMapper {

    private static let logger = Logger(subsystem: "SwiftRevenueCat", category: "SubscriptionDisplayMapper")

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    @MainActor
    static func map(
        customerInfo: CustomerInfo?,
        offerings: Offerings?,
        entitlementId: String? = nil
    ) -> SubscriptionDisplayModel {
        guard let info = customerInfo else { return .empty }

        let entitlement = EntitlementResolver.activeEntitlement(
            from: info,
            entitlementId: entitlementId
        )
        let proActive = entitlement != nil
        let isLifetime = proActive && entitlement?.expirationDate == nil

        return SubscriptionDisplayModel(
            isPro: proActive,
            isLifetime: isLifetime,
            planName: SubscriptionContentResolver.activePlanDisplayName(
                customerInfo: info,
                offerings: offerings
            ),
            priceText: SubscriptionContentResolver.activePlanPriceText(
                customerInfo: info,
                offerings: offerings
            ),
            expirationDate: entitlement.flatMap {
                $0.expirationDate.map { formatDate($0) }
            },
            purchaseDate: entitlement.flatMap {
                $0.latestPurchaseDate.map { formatDate($0) }
            },
            storeName: mapStore(entitlement?.store),
            isSandbox: entitlement?.isSandbox ?? false,
            willRenew: isLifetime ? false : (entitlement?.willRenew ?? false),
            isInBillingRetryPeriod: (entitlement?.billingIssueDetectedAt != nil)
                && (entitlement?.willRenew ?? false)
        )
    }

    private static func formatDate(_ date: Date) -> String {
        displayDateFormatter.string(from: date)
    }

    private static func mapStore(_ store: Store?) -> String {
        guard let store else { return "" }
        switch store {
        case .appStore: return SubscriptionL10n.storeAppStore
        case .macAppStore: return SubscriptionL10n.storeMacAppStore
        case .playStore: return SubscriptionL10n.storePlayStore
        case .stripe: return SubscriptionL10n.storeStripe
        case .promotional: return SubscriptionL10n.storePromotional
        default: return ""
        }
    }
}
