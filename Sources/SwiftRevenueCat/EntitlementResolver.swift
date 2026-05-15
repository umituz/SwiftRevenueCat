import RevenueCat

public enum EntitlementResolver {

    public static func activeEntitlement(from info: CustomerInfo?, entitlementId: String? = nil) -> EntitlementInfo? {
        guard let info else { return nil }

        if let id = entitlementId {
            return info.entitlements[id]
        }

        return info.entitlements.active.first?.value
    }

    public static func isPro(from info: CustomerInfo?, entitlementId: String? = nil) -> Bool {
        activeEntitlement(from: info, entitlementId: entitlementId) != nil
    }
}
