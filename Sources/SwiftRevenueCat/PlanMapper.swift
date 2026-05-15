import Foundation
import RevenueCat
import OSLog

enum PlanMapper {

    private static let logger = Logger(subsystem: "SwiftRevenueCat", category: "PlanMapper")

    static func mapPlans(from offerings: Offerings?) -> [Plan] {
        guard let packages = offerings?.current?.availablePackages,
              !packages.isEmpty else {
            return []
        }

        let allProducts = packages.map { $0.storeProduct }

        return packages
            .sorted { $0.storeProduct.price < $1.storeProduct.price }
            .map { package in
                mapPlan(from: package, allProducts: allProducts)
            }
    }

    private static func mapPlan(
        from package: Package,
        allProducts: [StoreProduct]
    ) -> Plan {
        let product = package.storeProduct
        let period = SubscriptionContentResolver.periodLabel(from: product)

        let badge: String? = {
            switch package.packageType {
            case .annual: return SubscriptionL10n.bestValue
            case .weekly: return SubscriptionL10n.mostPopular
            case .lifetime: return SubscriptionL10n.oneTime
            default: return nil
            }
        }()

        let savingsText: String? = {
            if package.packageType == .annual {
                return SubscriptionContentResolver.savingsPercentage(
                    annualProduct: product,
                    allProducts: allProducts
                )
            }
            return nil
        }()

        let discount = product.introductoryDiscount
        let hasFreeTrial = discount?.paymentMode == .freeTrial
        let trialPeriod = discount.map {
            SubscriptionContentResolver.formatPeriod($0.subscriptionPeriod)
        }
        let introductoryPrice = discount.map {
            $0.paymentMode == .freeTrial ? "Free" : $0.localizedPriceString
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
            package: package,
            savingsText: savingsText,
            hasFreeTrial: hasFreeTrial,
            trialPeriod: trialPeriod,
            introductoryPrice: introductoryPrice,
            offerDescription: offerDescription
        )
    }
}
