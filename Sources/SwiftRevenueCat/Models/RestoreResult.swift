import Foundation

public enum RestoreResult: Sendable {
    case restored
    case nothingToRestore
    case failed(SubscriptionError)

    public var errorMessage: String? {
        if case .failed(let error) = self {
            return error.errorDescription
        }
        return nil
    }

    public var isRestored: Bool {
        if case .restored = self { return true }
        return false
    }
}

extension RestoreResult: CustomStringConvertible {
    public var description: String {
        switch self {
        case .restored: return "RestoreResult.restored"
        case .nothingToRestore: return "RestoreResult.nothingToRestore"
        case .failed(let error): return "RestoreResult.failed(\(error))"
        }
    }
}
