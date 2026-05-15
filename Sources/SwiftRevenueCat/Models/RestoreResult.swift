import Foundation

public enum RestoreResult {
    case restored
    case nothingToRestore
    case failed(Error)

    public var errorMessage: String? {
        if case .failed(let error) = self {
            return error.localizedDescription
        }
        return nil
    }
}
