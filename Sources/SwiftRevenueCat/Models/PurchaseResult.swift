import Foundation

public enum PurchaseResult {
    case success
    case cancelled
    case notEntitled
    case failed(String)
}
