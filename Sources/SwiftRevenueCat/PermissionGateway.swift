import Foundation
import OSLog

public enum PermissionGateway {

    private static let logger = Logger(subsystem: "SwiftRevenueCat", category: "PermissionGateway")

    public static func checkCreation(
        isPro: Bool,
        currentCount: Int,
        limit: Int,
        type: String = "items"
    ) -> PermissionResult {
        if isPro {
            logger.debug("Creation ALLOWED: User is Pro")
            return PermissionResult(allowed: true)
        }

        if currentCount >= limit {
            logger.debug("Creation BLOCKED: \(currentCount) >= \(limit)")
            return PermissionResult(
                allowed: false,
                error: .freeLimitReached(current: currentCount, limit: limit, type: type)
            )
        }

        logger.debug("Creation ALLOWED: \(currentCount) < \(limit)")
        return PermissionResult(allowed: true)
    }

    public static func getLimitInfo(isPro: Bool, currentCount: Int, limit: Int) -> ProjectLimitInfo {
        ProjectLimitInfo(currentCount: currentCount, limit: limit, isPro: isPro)
    }
}
