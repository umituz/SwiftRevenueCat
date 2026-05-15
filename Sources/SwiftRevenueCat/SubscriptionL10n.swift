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

    // MARK: - Period Labels

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

    // MARK: - Savings

    public static func savings(_ percent: Int) -> String {
        String(localized: "subscription.savings_percent", defaultValue: "SAVE \(percent)%")
    }

    // MARK: - Permission Errors

    public static func freeLimitReached(current: Int, limit: Int, type: String) -> String {
        String(
            localized: "subscription.error.free_limit",
            defaultValue: "\(current)/\(limit) \(type) limit reached. Upgrade to Pro for unlimited."
        )
    }
}
