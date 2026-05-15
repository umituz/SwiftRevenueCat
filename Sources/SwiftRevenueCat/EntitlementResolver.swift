import RevenueCat

public enum EntitlementResolver {

    public static func activeEntitlement(from info: CustomerInfo?) -> EntitlementInfo? {
        guard let info else { return nil }
        return info.entitlements.active.first?.value
    }

    public static func isPro(from info: CustomerInfo?) -> Bool {
        activeEntitlement(from: info) != nil
    }
}
