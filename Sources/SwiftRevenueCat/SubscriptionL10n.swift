import Foundation

public enum SubscriptionL10n {

    // MARK: - Plan Badges

    public static var bestValue: String {
        String(localized: "subscription.badge.best_value", defaultValue: "Best Value")
    }

    public static var mostPopular: String {
        String(localized: "subscription.badge.most_popular", defaultValue: "Most Popular")
    }

    public static var oneTime: String {
        String(localized: "subscription.badge.one_time", defaultValue: "One Time")
    }

    // MARK: - Plan Names

    public static var freePlan: String {
        String(localized: "subscription.plan.free", defaultValue: "Free")
    }

    // MARK: - Period Labels (price suffix)

    public static var once: String {
        String(localized: "subscription.period.once", defaultValue: "once")
    }

    public static var perDay: String {
        String(localized: "subscription.period.day", defaultValue: "/ day")
    }

    public static var perWeek: String {
        String(localized: "subscription.period.week", defaultValue: "/ week")
    }

    public static var perMonth: String {
        String(localized: "subscription.period.month", defaultValue: "/ month")
    }

    public static var perYear: String {
        String(localized: "subscription.period.year", defaultValue: "/ year")
    }

    public static func perDays(_ count: Int) -> String {
        String(localized: "subscription.period.days", defaultValue: "/ \(count) days")
    }

    public static func perWeeks(_ count: Int) -> String {
        String(localized: "subscription.period.weeks", defaultValue: "/ \(count) weeks")
    }

    public static func perMonths(_ count: Int) -> String {
        String(localized: "subscription.period.months", defaultValue: "/ \(count) months")
    }

    public static func perYears(_ count: Int) -> String {
        String(localized: "subscription.period.years", defaultValue: "/ \(count) years")
    }

    // MARK: - Period Count Labels (standalone)

    public static var oneDay: String {
        String(localized: "subscription.period_count.one_day", defaultValue: "1 day")
    }

    public static var oneWeek: String {
        String(localized: "subscription.period_count.one_week", defaultValue: "1 week")
    }

    public static var oneMonth: String {
        String(localized: "subscription.period_count.one_month", defaultValue: "1 month")
    }

    public static var oneYear: String {
        String(localized: "subscription.period_count.one_year", defaultValue: "1 year")
    }

    public static func days(_ count: Int) -> String {
        String(localized: "subscription.period_count.days", defaultValue: "\(count) days")
    }

    public static func weeks(_ count: Int) -> String {
        String(localized: "subscription.period_count.weeks", defaultValue: "\(count) weeks")
    }

    public static func months(_ count: Int) -> String {
        String(localized: "subscription.period_count.months", defaultValue: "\(count) months")
    }

    public static func years(_ count: Int) -> String {
        String(localized: "subscription.period_count.years", defaultValue: "\(count) years")
    }

    // MARK: - Savings

    public static func savings(_ percent: Int) -> String {
        String(localized: "subscription.savings_percent", defaultValue: "SAVE \(percent)%")
    }

    // MARK: - Offer Descriptions

    public static func freeTrialOffer(
        trialPeriod: String,
        price: String
    ) -> String {
        String(
            localized: "subscription.offer.free_trial",
            defaultValue: "\(trialPeriod) free, then \(price)"
        )
    }

    public static func introOffer(
        introPrice: String,
        introPeriod: String,
        regularPrice: String
    ) -> String {
        String(
            localized: "subscription.offer.intro",
            defaultValue: "\(introPrice) for \(introPeriod), then \(regularPrice)"
        )
    }

    // MARK: - Permission Errors

    public static func freeLimitReached(
        current: Int,
        limit: Int,
        type: String
    ) -> String {
        String(
            localized: "subscription.error.free_limit",
            defaultValue: "\(current)/\(limit) \(type) limit reached. Upgrade to Pro for unlimited."
        )
    }

    // MARK: - Subscription Errors

    public static var errorNetwork: String {
        String(
            localized: "subscription.error.network",
            defaultValue: "Unable to connect. Please check your internet connection."
        )
    }

    public static var errorNotAllowed: String {
        String(
            localized: "subscription.error.not_allowed",
            defaultValue: "Purchase not allowed. Check your device restrictions."
        )
    }

    public static var errorStoreProblem: String {
        String(
            localized: "subscription.error.store_problem",
            defaultValue: "The App Store is temporarily unavailable. Please try again."
        )
    }

    public static var errorProductUnavailable: String {
        String(
            localized: "subscription.error.product_unavailable",
            defaultValue: "This product is not available for purchase."
        )
    }

    public static var errorInvalidApiKey: String {
        String(
            localized: "subscription.error.invalid_api_key",
            defaultValue: "Invalid API key"
        )
    }

    public static var errorConfigMissingApiKey: String {
        String(
            localized: "subscription.error.config_missing_key",
            defaultValue: "RevenueCat API key is missing or empty"
        )
    }

    public static var defaultItemName: String {
        String(
            localized: "subscription.default.item_name",
            defaultValue: "items"
        )
    }
}
