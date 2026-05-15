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
