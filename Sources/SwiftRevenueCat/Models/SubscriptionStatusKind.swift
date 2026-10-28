import Foundation

/// The full subscription lifecycle state, ready to bind to UI.
public enum SubscriptionStatusKind: String, Sendable, Equatable {
    /// No customer info yet (store not configured or still loading).
    case unknown
    /// No active entitlement.
    case notSubscribed
    /// Entitlement active and renewing (or lifetime).
    case active
    /// Entitlement active but the user turned off renewal.
    case willExpire
    /// Entitlement's expiration date is in the past.
    case expired
    /// Explicitly canceled by the app/user — reserved for app-specific flows.
    case canceled

    /// True while the user should keep premium benefits.
    public var isActive: Bool {
        switch self {
        case .active, .willExpire: return true
        default: return false
        }
    }

    /// Localized, user-facing status label.
    public var statusText: String {
        switch self {
        case .unknown: return SubscriptionL10n.statusUnknown
        case .notSubscribed: return SubscriptionL10n.freeTier
        case .active: return SubscriptionL10n.statusActive
        case .willExpire: return SubscriptionL10n.statusWillExpire
        case .expired: return SubscriptionL10n.statusExpired
        case .canceled: return SubscriptionL10n.statusCanceled
        }
    }
}
