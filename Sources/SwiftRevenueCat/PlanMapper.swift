import Foundation
import RevenueCat

enum PlanMapper {

    static func mapPlans(from offerings: Offerings?) -> [Plan] {
        guard let offering = currentOffering(from: offerings),
              !offering.availablePackages.isEmpty else {
            return []
        }
        let packages = offering.availablePackages

        let costAnalysis = SubscriptionPriceCalculator.analyzeCosts(packages: packages)

        return packages.map { package in
            mapPlan(from: package, costAnalysis: costAnalysis)
        }
    }

    /// Current offering, falling back to the first available offering when
    /// none is marked current — no hardcoded offering identifiers.
    private static func currentOffering(from offerings: Offerings?) -> Offering? {
        if let current = offerings?.current { return current }
        return offerings?.all.values
            .sorted { $0.identifier < $1.identifier }
            .first
    }

    // MARK: - Private

    private static func mapPlan(
        from package: Package,
        costAnalysis: SubscriptionPriceCalculator.CostAnalysis
    ) -> Plan {
        let product = package.storeProduct
        let period = SubscriptionContentResolver.periodLabel(from: product)
        let productId = product.productIdentifier

        let badge = PlanBadgeResolver.resolve(
            productId: productId,
            bestValueId: costAnalysis.bestValueId,
            packageType: package.packageType
        )

        let savingsText = SubscriptionPriceCalculator.savingsText(
            productId: productId,
            costAnalysis: costAnalysis
        )

        let discount = product.introductoryDiscount
        let hasFreeTrial = discount?.paymentMode == .freeTrial
        let trialPeriod = discount.map {
            SubscriptionContentResolver.formatPeriod($0.subscriptionPeriod)
        }
        let introductoryPrice = discount.map {
            OfferPriceResolver.introductoryPriceString(from: $0)
        }
        let offerDescription = discount.flatMap {
            SubscriptionContentResolver.buildOfferDescription(
                discount: $0,
                regularPrice: product.localizedPriceString
            )
        }

        return Plan(
            id: package.identifier,
            title: product.localizedTitle,
            price: product.localizedPriceString,
            period: period,
            badge: badge,
            packageType: package.packageType,
            savingsText: savingsText,
            hasFreeTrial: hasFreeTrial,
            trialPeriod: trialPeriod,
            introductoryPrice: introductoryPrice,
            offerDescription: offerDescription,
            revenueCatPackage: package
        )
    }
}
