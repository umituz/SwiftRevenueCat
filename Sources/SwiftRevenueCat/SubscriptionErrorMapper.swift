import Foundation
import RevenueCat
import StoreKit

enum SubscriptionErrorMapper {

    static func map(_ error: Error) -> SubscriptionError {
        if let rcError = error as? ErrorCode {
            return mapRevenueCatError(rcError, original: error)
        }

        if let storeKitError = error as? StoreKitError {
            return mapStoreKitError(storeKitError, original: error)
        }

        let nsError = error as NSError
        if nsError.domain == SKErrorDomain {
            return mapSKError(nsError)
        }

        return .unknown(error.localizedDescription)
    }

    private static func mapRevenueCatError(_ code: ErrorCode, original error: Error) -> SubscriptionError {
        switch code {
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
            return .apiKeyInvalid
        case .offlineConnectionError, .productRequestTimedOut:
            return .networkError
        case .purchaseInvalidError:
            return .purchaseNotAllowed
        case .productAlreadyPurchasedError:
            return .receiptInUse
        case .unknownError, .unexpectedBackendResponseError:
            return .unknown(error.localizedDescription)
        case .invalidAppUserIdError:
            return .apiKeyInvalid
        case .missingReceiptFileError:
            return .storeProblem
        case .logOutAnonymousUserError:
            return .unknown(error.localizedDescription)
        default:
            return .unknown(error.localizedDescription)
        }
    }

    private static func mapStoreKitError(_ error: StoreKitError, original: Error) -> SubscriptionError {
        switch error {
        case .userCancelled:
            return .purchaseCancelled
        case .networkError:
            return .networkError
        case .systemError, .notAvailableInStorefront, .notEntitled:
            return .storeProblem
        case .unknown, .unsupported:
            return .unknown(original.localizedDescription)
        @unknown default:
            return .unknown(original.localizedDescription)
        }
    }

    private static func mapSKError(_ nsError: NSError) -> SubscriptionError {
        switch nsError.code {
        case SKError.paymentCancelled.rawValue:
            return .purchaseCancelled
        case SKError.paymentInvalid.rawValue:
            return .purchaseNotAllowed
        case SKError.paymentNotAllowed.rawValue:
            return .purchaseNotAllowed
        case SKError.storeProductNotAvailable.rawValue:
            return .productNotAvailable
        case SKError.cloudServiceNetworkConnectionFailed.rawValue:
            return .networkError
        case SKError.clientInvalid.rawValue:
            return .purchaseNotAllowed
        case SKError.cloudServicePermissionDenied.rawValue, SKError.cloudServiceRevoked.rawValue:
            return .networkError
        case SKError.privacyAcknowledgementRequired.rawValue:
            return .purchaseNotAllowed
        case SKError.unauthorizedRequestData.rawValue,
             SKError.invalidOfferIdentifier.rawValue,
             SKError.invalidOfferPrice.rawValue,
             SKError.invalidSignature.rawValue,
             SKError.missingOfferParams.rawValue:
            return .storeProblem
        default:
            return .unknown(nsError.localizedDescription)
        }
    }
}
