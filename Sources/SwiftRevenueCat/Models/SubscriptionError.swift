import Foundation

public enum SubscriptionError: LocalizedError, Sendable {
    case networkError
    case purchaseCancelled
    case purchaseNotAllowed
    case storeProblem
    case productNotAvailable
    case receiptInUse
    case paymentPending
    case insufficientPermissions
    case apiKeyInvalid
    case apiKeyMissing
    case notConfigured
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .networkError:
            return SubscriptionL10n.errorNetwork
        case .purchaseCancelled:
            return nil
        case .purchaseNotAllowed:
            return SubscriptionL10n.errorNotAllowed
        case .storeProblem:
            return SubscriptionL10n.errorStoreProblem
        case .productNotAvailable:
            return SubscriptionL10n.errorProductUnavailable
        case .receiptInUse:
            return SubscriptionL10n.errorReceiptInUse
        case .paymentPending:
            return SubscriptionL10n.errorPaymentPending
        case .insufficientPermissions:
            return SubscriptionL10n.errorNotAllowed
        case .apiKeyInvalid:
            return SubscriptionL10n.errorInvalidApiKey
        case .apiKeyMissing:
            return SubscriptionL10n.errorConfigMissingApiKey
        case .notConfigured:
            return SubscriptionL10n.errorConfigMissingApiKey
        case .unknown(let message):
            return message
        }
    }

    public static func from(_ error: Error) -> SubscriptionError {
        SubscriptionErrorMapper.map(error)
    }
}

extension SubscriptionError: Equatable {
    public static func == (lhs: SubscriptionError, rhs: SubscriptionError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError, .networkError): return true
        case (.purchaseCancelled, .purchaseCancelled): return true
        case (.purchaseNotAllowed, .purchaseNotAllowed): return true
        case (.storeProblem, .storeProblem): return true
        case (.productNotAvailable, .productNotAvailable): return true
        case (.receiptInUse, .receiptInUse): return true
        case (.paymentPending, .paymentPending): return true
        case (.insufficientPermissions, .insufficientPermissions): return true
        case (.apiKeyInvalid, .apiKeyInvalid): return true
        case (.apiKeyMissing, .apiKeyMissing): return true
        case (.notConfigured, .notConfigured): return true
        case (.unknown(let a), .unknown(let b)): return a == b
        default: return false
        }
    }
}

extension SubscriptionError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .networkError: return "SubscriptionError.networkError"
        case .purchaseCancelled: return "SubscriptionError.purchaseCancelled"
        case .purchaseNotAllowed: return "SubscriptionError.purchaseNotAllowed"
        case .storeProblem: return "SubscriptionError.storeProblem"
        case .productNotAvailable: return "SubscriptionError.productNotAvailable"
        case .receiptInUse: return "SubscriptionError.receiptInUse"
        case .paymentPending: return "SubscriptionError.paymentPending"
        case .insufficientPermissions: return "SubscriptionError.insufficientPermissions"
        case .apiKeyInvalid: return "SubscriptionError.apiKeyInvalid"
        case .apiKeyMissing: return "SubscriptionError.apiKeyMissing"
        case .notConfigured: return "SubscriptionError.notConfigured"
        case .unknown(let msg): return "SubscriptionError.unknown(\(msg))"
        }
    }
}
