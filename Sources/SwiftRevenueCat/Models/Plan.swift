import Foundation
import RevenueCat

public struct Plan: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let price: String
    public let period: String
    public let badge: String?
    public let packageType: PackageType
    public let package: Package?
    public let savingsText: String?

    public init(
        id: String,
        title: String,
        price: String,
        period: String,
        badge: String?,
        packageType: PackageType,
        package: Package?,
        savingsText: String?
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.period = period
        self.badge = badge
        self.packageType = packageType
        self.package = package
        self.savingsText = savingsText
    }

    public static func == (lhs: Plan, rhs: Plan) -> Bool {
        lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.price == rhs.price
            && lhs.period == rhs.period
            && lhs.badge == rhs.badge
            && lhs.savingsText == rhs.savingsText
    }
}
