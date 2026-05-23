import Foundation
import RevenueCat

enum SubscriptionPriceCalculator {

    struct CostAnalysis {
        let costPerDayMap: [String: Decimal]
        let bestValueId: String?
        let mostExpensiveId: String?
    }

    private static let maxComparablePrice: Decimal = 999_999_999_999

    static func analyzeCosts(packages: [Package]) -> CostAnalysis {
        let allProducts = packages.map { $0.storeProduct }
        let costMap = buildCostPerDayMap(allProducts)
        let bestValueId = findCheapestPlanId(from: allProducts, costPerDayMap: costMap)
        let mostExpensiveId = findMostExpensivePlanId(from: allProducts, costPerDayMap: costMap)
        return CostAnalysis(
            costPerDayMap: costMap,
            bestValueId: bestValueId,
            mostExpensiveId: mostExpensiveId
        )
    }

    static func costPerDay(for product: StoreProduct) -> Decimal {
        guard let period = product.subscriptionPeriod else {
            return product.price
        }
        let days = PeriodConverter.daysInPeriod(period)
        guard days > 0 else { return product.price }
        return product.price / Decimal(days)
    }

    static func savingsPercentage(
        cheaperCostPerDay: Decimal,
        baselineCostPerDay: Decimal
    ) -> Int? {
        guard baselineCostPerDay > 0 else { return nil }
        guard cheaperCostPerDay < baselineCostPerDay else { return nil }

        let savings = ((baselineCostPerDay - cheaperCostPerDay) / baselineCostPerDay) * 100
        let rounded = Int(truncating: NSDecimalNumber(decimal: savings).rounding(accordingToBehavior: nil))
        guard rounded > 0 else { return nil }
        return rounded
    }

    static func savingsText(
        productId: String,
        costAnalysis: CostAnalysis
    ) -> String? {
        guard productId != costAnalysis.mostExpensiveId,
              let mostExpensiveId = costAnalysis.mostExpensiveId,
              let productCostPerDay = costAnalysis.costPerDayMap[productId],
              let mostExpensiveCostPerDay = costAnalysis.costPerDayMap[mostExpensiveId] else {
            return nil
        }

        guard let percentage = savingsPercentage(
            cheaperCostPerDay: productCostPerDay,
            baselineCostPerDay: mostExpensiveCostPerDay
        ) else {
            return nil
        }

        return SubscriptionL10n.savings(percentage)
    }

    // MARK: - Private

    private static func buildCostPerDayMap(_ products: [StoreProduct]) -> [String: Decimal] {
        var map: [String: Decimal] = [:]
        for product in products {
            map[product.productIdentifier] = costPerDay(for: product)
        }
        return map
    }

    private static func findCheapestPlanId(
        from products: [StoreProduct],
        costPerDayMap: [String: Decimal]
    ) -> String? {
        guard products.count > 1 else { return nil }
        return products.min(by: {
            let left = costPerDayMap[$0.productIdentifier] ?? maxComparablePrice
            let right = costPerDayMap[$1.productIdentifier] ?? maxComparablePrice
            return left < right
        })?.productIdentifier
    }

    private static func findMostExpensivePlanId(
        from products: [StoreProduct],
        costPerDayMap: [String: Decimal]
    ) -> String? {
        guard products.count > 1 else { return nil }
        return products.max(by: {
            let left = costPerDayMap[$0.productIdentifier] ?? 0
            let right = costPerDayMap[$1.productIdentifier] ?? 0
            return left < right
        })?.productIdentifier
    }
}
