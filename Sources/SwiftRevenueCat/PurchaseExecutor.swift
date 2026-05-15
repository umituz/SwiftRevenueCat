import Foundation
import RevenueCat
import OSLog

@MainActor
public final class PurchaseExecutor: PurchaseProviding {
    private let logger = Logger(subsystem: "SwiftRevenueCat", category: "PurchaseExecutor")

    public init() {}

    public func purchase(_ package: Package) async -> PurchaseResult {
        logger.info("Starting purchase for: \(package.identifier)")

        do {
            let result = try await Purchases.shared.purchase(package: package)

            if result.userCancelled {
                logger.info("User cancelled purchase")
                return .cancelled
            }

            let isEntitled = EntitlementResolver.isPro(from: result.customerInfo)

            if isEntitled {
                logger.info("Purchase successful and entitled")
                return .success
            } else {
                logger.warning("Purchase finished but no active entitlement")
                return .notEntitled
            }
        } catch {
            logger.error("Purchase failed: \(error.localizedDescription)")
            return .failed(error.localizedDescription)
        }
    }

    public func restorePurchases() async -> RestoreResult {
        logger.info("Starting restore purchases")

        do {
            let info = try await Purchases.shared.restorePurchases()
            let isEntitled = EntitlementResolver.isPro(from: info)

            if isEntitled {
                logger.info("Restore successful - Pro status found")
                return .restored
            } else {
                logger.info("Restore finished - No Pro status found")
                return .nothingToRestore
            }
        } catch {
            logger.error("Restore failed: \(error.localizedDescription)")
            return .failed(error.localizedDescription)
        }
    }
}
