import Foundation

/// Billing period of a subscription product, classified from the
/// product identifier (entitlements expose no structured period).
public enum SubscriptionPeriodKind: String, Sendable, Equatable {
    case none
    case monthly
    case yearly

    /// Heuristic classification from a product identifier such as
    /// `"com.example.app.premium_monthly"` or `"...premium_annual"`.
    public static func from(productIdentifier: String) -> SubscriptionPeriodKind {
        let id = productIdentifier.lowercased()
        if id.contains("month") {
            return .monthly
        }
        if id.contains("year") || id.contains("annual") {
            return .yearly
        }
        return .none
    }

    /// Localized, user-facing period name ("Monthly", "Yearly", "Free").
    public var displayName: String {
        switch self {
        case .none: return SubscriptionL10n.freeTier
        case .monthly: return SubscriptionL10n.periodMonthly
        case .yearly: return SubscriptionL10n.periodYearly
        }
    }
}
