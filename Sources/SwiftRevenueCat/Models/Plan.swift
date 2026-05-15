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
    public let hasFreeTrial: Bool
    public let trialPeriod: String?
    public let introductoryPrice: String?
    public let offerDescription: String?

    public init(
        id: String,
        title: String,
        price: String,
        period: String,
        badge: String?,
        packageType: PackageType,
        package: Package?,
        savingsText: String?,
        hasFreeTrial: Bool = false,
        trialPeriod: String? = nil,
        introductoryPrice: String? = nil,
        offerDescription: String? = nil
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.period = period
        self.badge = badge
        self.packageType = packageType
        self.package = package
        self.savingsText = savingsText
        self.hasFreeTrial = hasFreeTrial
        self.trialPeriod = trialPeriod
        self.introductoryPrice = introductoryPrice
        self.offerDescription = offerDescription
    }

    public static func == (lhs: Plan, rhs: Plan) -> Bool {
        lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.price == rhs.price
            && lhs.period == rhs.period
            && lhs.badge == rhs.badge
            && lhs.savingsText == rhs.savingsText
            && lhs.hasFreeTrial == rhs.hasFreeTrial
            && lhs.trialPeriod == rhs.trialPeriod
            && lhs.introductoryPrice == rhs.introductoryPrice
            && lhs.offerDescription == rhs.offerDescription
    }
}
