import Foundation

public enum RestoreResult {
    case restored
    case nothingToRestore
    case failed(String)
}
