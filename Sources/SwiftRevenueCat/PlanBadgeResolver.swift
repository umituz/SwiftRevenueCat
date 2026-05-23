import Foundation
import RevenueCat

enum PlanBadgeResolver {

    static func resolve(
        productId: String,
        bestValueId: String?,
        packageType: PackageType
    ) -> String? {
        if productId == bestValueId {
            return SubscriptionL10n.bestValue
        }
        if packageType == .lifetime {
            return SubscriptionL10n.oneTime
        }
        return nil
    }
}
