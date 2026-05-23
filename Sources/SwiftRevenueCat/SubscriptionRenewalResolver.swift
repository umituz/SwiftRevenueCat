import Foundation
import RevenueCat

enum SubscriptionRenewalResolver {

    static func willRenew(isLifetime: Bool, entitlement: EntitlementInfo?) -> Bool {
        guard !isLifetime else { return false }
        return entitlement?.willRenew ?? false
    }

    static func isInBillingRetry(entitlement: EntitlementInfo?) -> Bool {
        guard let entitlement else { return false }
        let hasBillingIssue = entitlement.billingIssueDetectedAt != nil
        let isRenewing = entitlement.willRenew
        return hasBillingIssue && isRenewing
    }
}
