import Foundation

public enum PurchaseResult: Sendable {
    case success
    case cancelled
    case notEntitled
    case failed(SubscriptionError)

    public var errorMessage: String? {
        if case .failed(let error) = self {
            return error.errorDescription
        }
        return nil
    }

    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    public var isCancelled: Bool {
        if case .cancelled = self { return true }
        return false
    }
}

extension PurchaseResult: CustomStringConvertible {
    public var description: String {
        switch self {
        case .success: return "PurchaseResult.success"
        case .cancelled: return "PurchaseResult.cancelled"
        case .notEntitled: return "PurchaseResult.notEntitled"
        case .failed(let error): return "PurchaseResult.failed(\(error))"
        }
    }
}
