import Foundation
import RevenueCat

enum PlanMapper {

    static func mapPlans(from offerings: Offerings?) -> [Plan] {
        guard let packages = offerings?.current?.availablePackages,
              !packages.isEmpty else {
            return []
        }

        let costAnalysis = SubscriptionPriceCalculator.analyzeCosts(packages: packages)

        return packages.map { package in
            mapPlan(from: package, costAnalysis: costAnalysis)
        }
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
