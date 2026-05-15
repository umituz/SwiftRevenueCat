import Foundation
import RevenueCat

@MainActor
public protocol PurchaseProviding: AnyObject {
    func purchase(_ package: Package) async -> PurchaseResult
    func restorePurchases() async -> RestoreResult
}
