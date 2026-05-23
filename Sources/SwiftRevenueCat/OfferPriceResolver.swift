import Foundation
import RevenueCat

enum OfferPriceResolver {

    static func introductoryPriceString(from discount: StoreProductDiscount) -> String {
        guard discount.paymentMode == .freeTrial else {
            return discount.localizedPriceString
        }
        return SubscriptionL10n.freeTier
    }
}
