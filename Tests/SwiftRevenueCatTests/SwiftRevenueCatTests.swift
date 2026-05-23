import Testing
import Foundation
@testable import SwiftRevenueCat
import RevenueCat

// MARK: - PeriodConverter

@Suite("PeriodConverter")
struct PeriodConverterTests {

    @Test("days in single day period")
    func daysInDayPeriod() {
        let period = SubscriptionPeriod(value: 1, unit: .day)
        #expect(PeriodConverter.daysInPeriod(period) == 1)
    }

    @Test("days in single week period")
    func daysInWeekPeriod() {
        let period = SubscriptionPeriod(value: 1, unit: .week)
        #expect(PeriodConverter.daysInPeriod(period) == 7)
    }

    @Test("days in single month period")
    func daysInMonthPeriod() {
        let period = SubscriptionPeriod(value: 1, unit: .month)
        #expect(PeriodConverter.daysInPeriod(period) == 30)
    }

    @Test("days in single year period")
    func daysInYearPeriod() {
        let period = SubscriptionPeriod(value: 1, unit: .year)
        #expect(PeriodConverter.daysInPeriod(period) == 365)
    }

    @Test("days in 6-month period")
    func daysIn6MonthPeriod() {
        let period = SubscriptionPeriod(value: 6, unit: .month)
        #expect(PeriodConverter.daysInPeriod(period) == 180)
    }

    @Test("days in 2-week period")
    func daysIn2WeekPeriod() {
        let period = SubscriptionPeriod(value: 2, unit: .week)
        #expect(PeriodConverter.daysInPeriod(period) == 14)
    }

    @Test("toDateComponents for day period")
    func toDateComponentsDay() {
        let period = SubscriptionPeriod(value: 3, unit: .day)
        let components = PeriodConverter.toDateComponents(period)
        #expect(components.day == 3)
    }

    @Test("toDateComponents for month period")
    func toDateComponentsMonth() {
        let period = SubscriptionPeriod(value: 6, unit: .month)
        let components = PeriodConverter.toDateComponents(period)
        #expect(components.month == 6)
    }

    @Test("toDateComponents for year period")
    func toDateComponentsYear() {
        let period = SubscriptionPeriod(value: 1, unit: .year)
        let components = PeriodConverter.toDateComponents(period)
        #expect(components.year == 1)
    }

    @Test("toDateComponents for week period")
    func toDateComponentsWeek() {
        let period = SubscriptionPeriod(value: 2, unit: .week)
        let components = PeriodConverter.toDateComponents(period)
        #expect(components.weekOfMonth == 2)
    }
}

// MARK: - PlanBadgeResolver

@Suite("PlanBadgeResolver")
struct PlanBadgeResolverTests {

    @Test("returns Best Value when productId matches bestValueId")
    func bestValueBadge() {
        let badge = PlanBadgeResolver.resolve(
            productId: "com.app.annual",
            bestValueId: "com.app.annual",
            packageType: .annual
        )
        #expect(badge == SubscriptionL10n.bestValue)
    }

    @Test("returns One Time for lifetime package type")
    func lifetimeBadge() {
        let badge = PlanBadgeResolver.resolve(
            productId: "com.app.lifetime",
            bestValueId: "com.app.annual",
            packageType: .lifetime
        )
        #expect(badge == SubscriptionL10n.oneTime)
    }

    @Test("returns nil for standard non-best-value plan")
    func noBadge() {
        let badge = PlanBadgeResolver.resolve(
            productId: "com.app.monthly",
            bestValueId: "com.app.annual",
            packageType: .monthly
        )
        #expect(badge == nil)
    }

    @Test("best value takes priority when both conditions match")
    func bestValueTakesPriorityOverLifetime() {
        let badge = PlanBadgeResolver.resolve(
            productId: "com.app.lifetime",
            bestValueId: "com.app.lifetime",
            packageType: .lifetime
        )
        #expect(badge == SubscriptionL10n.bestValue)
    }

    @Test("returns nil when bestValueId is nil and not lifetime")
    func nilBestValueId() {
        let badge = PlanBadgeResolver.resolve(
            productId: "com.app.monthly",
            bestValueId: nil,
            packageType: .monthly
        )
        #expect(badge == nil)
    }

    @Test("lifetime gets badge even when bestValueId is nil")
    func lifetimeBadgeWithNilBestValueId() {
        let badge = PlanBadgeResolver.resolve(
            productId: "com.app.lifetime",
            bestValueId: nil,
            packageType: .lifetime
        )
        #expect(badge == SubscriptionL10n.oneTime)
    }
}

// MARK: - SubscriptionRenewalResolver

@Suite("SubscriptionRenewalResolver")
struct SubscriptionRenewalResolverTests {

    @Test("lifetime never renews")
    func lifetimeDoesNotRenew() {
        #expect(SubscriptionRenewalResolver.willRenew(isLifetime: true, entitlement: nil) == false)
    }

    @Test("nil entitlement does not renew")
    func nilEntitlementDoesNotRenew() {
        #expect(SubscriptionRenewalResolver.willRenew(isLifetime: false, entitlement: nil) == false)
    }

    @Test("not in billing retry when entitlement is nil")
    func nilEntitlementNotInBillingRetry() {
        #expect(SubscriptionRenewalResolver.isInBillingRetry(entitlement: nil) == false)
    }
}

// MARK: - SubscriptionPriceCalculator

@Suite("SubscriptionPriceCalculator")
struct SubscriptionPriceCalculatorTests {

    @Test("savingsPercentage calculates 50% correctly")
    func savingsPercentage50() {
        let result = SubscriptionPriceCalculator.savingsPercentage(
            cheaperCostPerDay: Decimal(0.50),
            baselineCostPerDay: Decimal(1.00)
        )
        #expect(result == 50)
    }

    @Test("savingsPercentage returns nil when baseline is zero")
    func savingsPercentageZeroBaseline() {
        let result = SubscriptionPriceCalculator.savingsPercentage(
            cheaperCostPerDay: Decimal(0.50),
            baselineCostPerDay: Decimal(0)
        )
        #expect(result == nil)
    }

    @Test("savingsPercentage returns nil when prices are equal")
    func savingsPercentageEqual() {
        let result = SubscriptionPriceCalculator.savingsPercentage(
            cheaperCostPerDay: Decimal(1.00),
            baselineCostPerDay: Decimal(1.00)
        )
        #expect(result == nil)
    }

    @Test("savingsPercentage returns nil when cheaper is more expensive")
    func savingsPercentageReversed() {
        let result = SubscriptionPriceCalculator.savingsPercentage(
            cheaperCostPerDay: Decimal(1.50),
            baselineCostPerDay: Decimal(1.00)
        )
        #expect(result == nil)
    }

    @Test("savingsPercentage returns nil for sub-1% savings")
    func savingsPercentageTinySavings() {
        let result = SubscriptionPriceCalculator.savingsPercentage(
            cheaperCostPerDay: Decimal(string: "0.999") ?? Decimal(0),
            baselineCostPerDay: Decimal(1)
        )
        #expect(result == nil)
    }

    @Test("savingsPercentage for 25% savings")
    func savingsPercentage25() {
        let result = SubscriptionPriceCalculator.savingsPercentage(
            cheaperCostPerDay: Decimal(string: "0.75") ?? Decimal(0),
            baselineCostPerDay: Decimal(1)
        )
        #expect(result == 25)
    }
}

// MARK: - SubscriptionError

@Suite("SubscriptionError")
struct SubscriptionErrorTests {

    @Test("all cases except purchaseCancelled have non-nil descriptions")
    func errorDescriptions() {
        let casesWithDescriptions: [SubscriptionError] = [
            .networkError,
            .purchaseNotAllowed,
            .storeProblem,
            .productNotAvailable,
            .receiptInUse,
            .paymentPending,
            .insufficientPermissions,
            .apiKeyInvalid,
            .apiKeyMissing,
            .notConfigured,
            .unknown("test error")
        ]
        for error in casesWithDescriptions {
            #expect(error.errorDescription != nil, "\(error) should have non-nil description")
        }
        #expect(SubscriptionError.purchaseCancelled.errorDescription == nil)
    }

    @Test("unknown error preserves message")
    func unknownErrorMessage() {
        let error = SubscriptionError.unknown("Something went wrong")
        #expect(error.errorDescription == "Something went wrong")
    }

    @Test("CustomStringConvertible produces readable output")
    func customStringConvertible() {
        #expect(SubscriptionError.networkError.description == "SubscriptionError.networkError")
        #expect(SubscriptionError.purchaseCancelled.description == "SubscriptionError.purchaseCancelled")
        #expect(SubscriptionError.notConfigured.description == "SubscriptionError.notConfigured")
    }

    @Test("synthesized Equatable works correctly")
    func equatable() {
        #expect(SubscriptionError.networkError == SubscriptionError.networkError)
        #expect(SubscriptionError.networkError != SubscriptionError.storeProblem)
        #expect(SubscriptionError.unknown("a") == SubscriptionError.unknown("a"))
        #expect(SubscriptionError.unknown("a") != SubscriptionError.unknown("b"))
    }

    @Test("from() delegates to SubscriptionErrorMapper")
    func fromDelegate() {
        let nsError = NSError(domain: "SKErrorDomain", code: 2, userInfo: nil)
        let result = SubscriptionError.from(nsError)
        #expect(result == .purchaseCancelled)
    }
}

// MARK: - PurchaseResult

@Suite("PurchaseResult")
struct PurchaseResultTests {

    @Test("success state")
    func success() {
        let result = PurchaseResult.success
        #expect(result.isSuccess)
        #expect(!result.isCancelled)
        #expect(result.errorMessage == nil)
    }

    @Test("cancelled state")
    func cancelled() {
        let result = PurchaseResult.cancelled
        #expect(!result.isSuccess)
        #expect(result.isCancelled)
        #expect(result.errorMessage == nil)
    }

    @Test("failed state with error message")
    func failed() {
        let result = PurchaseResult.failed(.networkError)
        #expect(!result.isSuccess)
        #expect(!result.isCancelled)
        #expect(result.errorMessage != nil)
    }

    @Test("notEntitled state")
    func notEntitled() {
        let result = PurchaseResult.notEntitled
        #expect(!result.isSuccess)
        #expect(!result.isCancelled)
        #expect(result.errorMessage == nil)
    }

    @Test("description output")
    func description() {
        #expect(PurchaseResult.success.description == "PurchaseResult.success")
        #expect(PurchaseResult.cancelled.description == "PurchaseResult.cancelled")
        #expect(PurchaseResult.notEntitled.description == "PurchaseResult.notEntitled")
    }
}

// MARK: - RestoreResult

@Suite("RestoreResult")
struct RestoreResultTests {

    @Test("restored state")
    func restored() {
        let result = RestoreResult.restored
        #expect(result.isRestored)
        #expect(result.errorMessage == nil)
    }

    @Test("nothingToRestore state")
    func nothingToRestore() {
        let result = RestoreResult.nothingToRestore
        #expect(!result.isRestored)
        #expect(result.errorMessage == nil)
    }

    @Test("failed state with error message")
    func failed() {
        let result = RestoreResult.failed(.networkError)
        #expect(!result.isRestored)
        #expect(result.errorMessage != nil)
    }

    @Test("description output")
    func description() {
        #expect(RestoreResult.restored.description == "RestoreResult.restored")
        #expect(RestoreResult.nothingToRestore.description == "RestoreResult.nothingToRestore")
    }
}

// MARK: - SubscriptionDisplayModel

@Suite("SubscriptionDisplayModel")
struct SubscriptionDisplayModelTests {

    @Test("empty factory sets free tier defaults")
    func emptyFactory() {
        let model = SubscriptionDisplayModel.empty
        #expect(!model.isSubscribed)
        #expect(!model.isLifetime)
        #expect(model.planName == SubscriptionL10n.freeTier)
        #expect(model.priceText == "")
        #expect(model.expirationDate == nil)
        #expect(model.purchaseDate == nil)
        #expect(model.storeName == "")
        #expect(!model.willRenew)
        #expect(!model.isInBillingRetryPeriod)
    }

    @Test("equality works for identical models")
    func equality() {
        let a = SubscriptionDisplayModel.empty
        let b = SubscriptionDisplayModel.empty
        #expect(a == b)
    }

    @Test("custom init preserves values")
    func customInit() {
        let model = SubscriptionDisplayModel(
            isSubscribed: true,
            isLifetime: false,
            planName: "Pro",
            priceText: "$9.99 /month",
            expirationDate: "Jan 2027",
            purchaseDate: "Jan 2026",
            storeName: "App Store",
            willRenew: true,
            isInBillingRetryPeriod: true
        )
        #expect(model.isSubscribed)
        #expect(!model.isLifetime)
        #expect(model.planName == "Pro")
        #expect(model.priceText == "$9.99 /month")
        #expect(model.expirationDate == "Jan 2027")
        #expect(model.purchaseDate == "Jan 2026")
        #expect(model.storeName == "App Store")
        #expect(model.willRenew)
        #expect(model.isInBillingRetryPeriod)
    }
}

// MARK: - SubscriptionStatus

@Suite("SubscriptionStatus")
struct SubscriptionStatusTests {

    @Test("init preserves values")
    func initValues() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let status = SubscriptionStatus(
            isSubscribed: true,
            expirationDate: date,
            isActive: true
        )
        #expect(status.isSubscribed)
        #expect(status.expirationDate == date)
        #expect(status.isActive)
    }

    @Test("equality works")
    func equality() {
        let a = SubscriptionStatus(isSubscribed: false, expirationDate: nil, isActive: false)
        let b = SubscriptionStatus(isSubscribed: false, expirationDate: nil, isActive: false)
        #expect(a == b)
    }

    @Test("Sendable conformance compiles")
    func sendableConformance() {
        let status = SubscriptionStatus(isSubscribed: true, expirationDate: nil, isActive: true)
        let _: any Sendable = status
    }
}

// MARK: - TrialEligibility

@Suite("TrialEligibility")
struct TrialEligibilityTests {

    @Test("all cases are constructible")
    func allCases() {
        let cases: [TrialEligibility] = [.eligible, .ineligible, .unknown, .noOfferAvailable]
        #expect(cases.count == 4)
    }
}

// MARK: - SubscriptionL10n

@Suite("SubscriptionL10n")
struct SubscriptionL10nTests {

    @Test("savings formats percentage value")
    func savings() {
        let result = SubscriptionL10n.savings(42)
        #expect(result.contains("42"))
    }

    @Test("freeTrialOffer interpolates both parameters")
    func freeTrialOffer() {
        let result = SubscriptionL10n.freeTrialOffer(trialPeriod: "1 week", price: "$9.99")
        #expect(result.contains("1 week"))
        #expect(result.contains("$9.99"))
    }

    @Test("introOffer interpolates all three parameters")
    func introOffer() {
        let result = SubscriptionL10n.introOffer(
            introPrice: "$0.99",
            introPeriod: "1 month",
            regularPrice: "$9.99"
        )
        #expect(result.contains("$0.99"))
        #expect(result.contains("1 month"))
        #expect(result.contains("$9.99"))
    }

    @Test("planPricePeriod interpolates price and period")
    func planPricePeriod() {
        let result = SubscriptionL10n.planPricePeriod(price: "$9.99", period: "/month")
        #expect(result.contains("$9.99"))
        #expect(result.contains("/month"))
    }

    @Test("error messages are non-empty")
    func errorMessages() {
        #expect(!SubscriptionL10n.errorNetwork.isEmpty)
        #expect(!SubscriptionL10n.errorNotAllowed.isEmpty)
        #expect(!SubscriptionL10n.errorStoreProblem.isEmpty)
        #expect(!SubscriptionL10n.errorProductUnavailable.isEmpty)
        #expect(!SubscriptionL10n.errorReceiptInUse.isEmpty)
        #expect(!SubscriptionL10n.errorPaymentPending.isEmpty)
    }
}

// MARK: - SubscriptionErrorMapper

@Suite("SubscriptionErrorMapper")
struct SubscriptionErrorMapperTests {

    @Test("maps SKErrorDomain code 2 to purchaseCancelled")
    func skErrorCancel() {
        let error = NSError(domain: "SKErrorDomain", code: 2, userInfo: nil)
        let result = SubscriptionError.from(error)
        #expect(result == .purchaseCancelled)
    }

    @Test("maps SKErrorDomain code 0 to purchaseNotAllowed")
    func skErrorNotAllowed() {
        let error = NSError(domain: "SKErrorDomain", code: 0, userInfo: nil)
        let result = SubscriptionError.from(error)
        #expect(result == .purchaseNotAllowed)
    }

    @Test("maps SKErrorDomain code 3 to storeProblem")
    func skErrorStoreProblem() {
        let error = NSError(domain: "SKErrorDomain", code: 3, userInfo: nil)
        let result = SubscriptionError.from(error)
        #expect(result == .storeProblem)
    }

    @Test("maps SKErrorDomain unknown code to unknown")
    func skErrorUnknown() {
        let error = NSError(
            domain: "SKErrorDomain",
            code: 999,
            userInfo: [NSLocalizedDescriptionKey: "test"]
        )
        let result = SubscriptionError.from(error)
        if case .unknown = result {
            // expected
        } else {
            Issue.record("Expected .unknown, got \(result)")
        }
    }

    @Test("maps unknown error domain to unknown")
    func unknownErrorDomain() {
        let error = NSError(domain: "com.unknown.error", code: 42, userInfo: nil)
        let result = SubscriptionError.from(error)
        if case .unknown = result {
            // expected
        } else {
            Issue.record("Expected .unknown, got \(result)")
        }
    }
}
