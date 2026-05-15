import Foundation

public struct PermissionResult: Sendable {
    public let allowed: Bool
    public let error: PermissionError?

    public init(allowed: Bool, error: PermissionError? = nil) {
        self.allowed = allowed
        self.error = error
    }

    public var isAllowed: Bool { allowed }
}

public enum PermissionError: LocalizedError, Sendable {
    case freeLimitReached(current: Int, limit: Int, type: String)

    public var errorDescription: String? {
        switch self {
        case .freeLimitReached(let current, let limit, let type):
            return SubscriptionL10n.freeLimitReached(current: current, limit: limit, type: type)
        }
    }
}

public struct ProjectLimitInfo: Sendable {
    public let currentCount: Int
    public let limit: Int
    public let isPro: Bool
    public let isUnlimited: Bool
    public let remainingSlots: Int

    public init(currentCount: Int, limit: Int, isPro: Bool) {
        self.currentCount = currentCount
        self.limit = limit
        self.isPro = isPro
        self.isUnlimited = isPro
        self.remainingSlots = isPro ? Int.max : max(0, limit - currentCount)
    }

    public var isAtLimit: Bool { !isUnlimited && currentCount >= limit }
}
