import Foundation
import RevenueCat

public enum SubscriptionError: LocalizedError, Sendable {
    case networkError
    case purchaseCancelled
    case purchaseNotAllowed
    case storeProblem
    case productNotAvailable
    case receiptInUse
    case paymentPending
    case insufficientPermissions
    case configurationError(String)
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
        case .configurationError(let message):
            return message
        case .unknown(let message):
            return message
        }
    }

    public static func from(_ error: Error) -> SubscriptionError {
        if let rcError = error as? ErrorCode {
            switch rcError {
            case .purchaseCancelledError:
                return .purchaseCancelled
            case .networkError:
                return .networkError
            case .purchaseNotAllowedError:
                return .purchaseNotAllowed
            case .storeProblemError:
                return .storeProblem
            case .productNotAvailableForPurchaseError:
                return .productNotAvailable
            case .receiptAlreadyInUseError, .receiptInUseByOtherSubscriberError:
                return .receiptInUse
            case .paymentPendingError:
                return .paymentPending
            case .insufficientPermissionsError:
                return .insufficientPermissions
            case .invalidCredentialsError, .configurationError:
                return .configurationError(SubscriptionL10n.errorInvalidApiKey)
            case .offlineConnectionError:
                return .networkError
            case .productRequestTimedOut:
                return .networkError
            case .purchaseInvalidError:
                return .storeProblem
            case .productAlreadyPurchasedError:
                return .receiptInUse
            default:
                return .unknown(error.localizedDescription)
            }
        }

        let nsError = error as NSError
        if nsError.domain == "SKErrorDomain" && nsError.code == 2 {
            return .purchaseCancelled
        }

        return .unknown(error.localizedDescription)
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
        case .configurationError(let msg): return "SubscriptionError.configurationError(\(msg))"
        case .unknown(let msg): return "SubscriptionError.unknown(\(msg))"
        }
    }
}
