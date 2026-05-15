import Foundation

public enum PurchaseResult {
    case success
    case cancelled
    case notEntitled
    case failed(Error)

    public var errorMessage: String? {
        if case .failed(let error) = self {
            return error.localizedDescription
        }
        return nil
    }
}
