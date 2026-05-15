import Foundation
import RevenueCat

public enum SubscriptionError: LocalizedError {
    case networkError(underlying: Error)
    case purchaseCancelled
    case purchaseNotAllowed
    case storeProblem(underlying: Error)
    case productNotAvailable
    case configurationError(String)
    case unknown(underlying: Error)

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
        case .configurationError(let message):
            return message
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    public static func from(_ error: Error) -> SubscriptionError {
        if let rcError = error as? ErrorCode {
            switch rcError {
            case .purchaseCancelledError:
                return .purchaseCancelled
            case .networkError:
                return .networkError(underlying: error)
            case .purchaseNotAllowedError:
                return .purchaseNotAllowed
            case .storeProblemError:
                return .storeProblem(underlying: error)
            case .productNotAvailableForPurchaseError:
                return .productNotAvailable
            case .invalidCredentialsError:
                return .configurationError(SubscriptionL10n.errorInvalidApiKey)
            default:
                return .unknown(underlying: error)
            }
        }

        let nsError = error as NSError
        if nsError.domain == "SKErrorDomain" && nsError.code == 2 {
            return .purchaseCancelled
        }

        return .unknown(underlying: error)
    }
}
