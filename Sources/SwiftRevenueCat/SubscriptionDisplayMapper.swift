import Foundation
import RevenueCat

enum SubscriptionDisplayMapper {

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
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
        let subscribed = entitlement != nil
        let isLifetime = subscribed && entitlement?.expirationDate == nil

        return SubscriptionDisplayModel(
            isSubscribed: subscribed,
            isLifetime: isLifetime,
            planName: SubscriptionContentResolver.activePlanDisplayName(
                customerInfo: info,
                offerings: offerings,
                entitlementId: entitlementId
            ),
            priceText: SubscriptionContentResolver.activePlanPriceText(
                customerInfo: info,
                offerings: offerings,
                entitlementId: entitlementId
            ),
            expirationDate: entitlement.flatMap {
                $0.expirationDate.map { formatDate($0) }
            },
            purchaseDate: entitlement.flatMap {
                $0.latestPurchaseDate.map { formatDate($0) }
            },
            storeName: mapStore(entitlement?.store),
            willRenew: SubscriptionRenewalResolver.willRenew(
                isLifetime: isLifetime,
                entitlement: entitlement
            ),
            isInBillingRetryPeriod: SubscriptionRenewalResolver.isInBillingRetry(
                entitlement: entitlement
            )
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
