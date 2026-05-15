import Foundation
import RevenueCat
import OSLog

public enum PlanMapper {

    private static let logger = Logger(subsystem: "SwiftRevenueCat", category: "PlanMapper")

    public static func mapPlans(from offerings: Offerings?) -> [Plan] {
        guard let packages = offerings?.current?.availablePackages, !packages.isEmpty else {
            return []
        }

        let allProducts = packages.map { $0.storeProduct }

        return packages
            .sorted { $0.storeProduct.price < $1.storeProduct.price }
            .map { package in
                mapPlan(from: package, allProducts: allProducts)
            }
    }

    private static func mapPlan(from package: Package, allProducts: [StoreProduct]) -> Plan {
        let product = package.storeProduct
        let period = SubscriptionContentResolver.periodLabel(from: product)

        let badge: String? = {
            switch package.packageType {
            case .annual: return "Best Value"
            case .weekly: return "Most Popular"
            case .lifetime: return "One Time"
            default: return nil
            }
        }()

        let savingsText: String? = {
            if package.packageType == .annual {
                return SubscriptionContentResolver.savingsPercentage(annualProduct: product, allProducts: allProducts)
            }
            return nil
        }()

        return Plan(
            id: package.identifier,
            title: product.localizedTitle,
            price: product.localizedPriceString,
            period: period,
            badge: badge,
            packageType: package.packageType,
            package: package,
            savingsText: savingsText
        )
    }
}
