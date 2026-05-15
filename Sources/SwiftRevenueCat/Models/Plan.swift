import Foundation
import RevenueCat

public struct Plan: Identifiable {
    public let id: String
    public let title: String
    public let price: String
    public let period: String
    public let badge: String?
    public let packageType: PackageType
    public let package: Package?
    public let savingsText: String?
}
