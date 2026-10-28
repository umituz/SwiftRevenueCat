import Foundation

public enum SubscriptionL10n {

    // MARK: - Plan Badges

    public static var bestValue: String {
        String(localized: "subscription.badge.best_value", defaultValue: "Best Value")
    }

    public static var oneTime: String {
        String(localized: "subscription.badge.one_time", defaultValue: "One Time")
    }

    // MARK: - Tier Names

    public static var freeTier: String {
        String(localized: "subscription.tier.free", defaultValue: "Free")
    }

    // MARK: - Status Labels

    public static var statusActive: String {
        String(localized: "subscription.status.active", defaultValue: "Active")
    }

    public static var statusExpired: String {
        String(localized: "subscription.status.expired", defaultValue: "Expired")
    }

    public static var statusWillExpire: String {
        String(localized: "subscription.status.will_expire", defaultValue: "Expires Soon")
    }

    public static var statusCanceled: String {
        String(localized: "subscription.status.canceled", defaultValue: "Canceled")
    }

    public static var statusUnknown: String {
        String(localized: "subscription.status.unknown", defaultValue: "Loading…")
    }

    // MARK: - Period Names

    public static var periodMonthly: String {
        String(localized: "subscription.period.monthly", defaultValue: "Monthly")
    }

    public static var periodYearly: String {
        String(localized: "subscription.period.yearly", defaultValue: "Yearly")
    }

    // MARK: - Period Labels

    public static var once: String {
        String(localized: "subscription.period.once", defaultValue: "once")
    }

    public static func periodPrefix(_ period: String) -> String {
        String(localized: "subscription.period.prefix", defaultValue: "/\(period)")
    }

    public static func planPricePeriod(price: String, period: String) -> String {
        String(localized: "subscription.plan.price_period", defaultValue: "\(price) \(period)")
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

    // MARK: - Error Messages

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

    public static var errorReceiptInUse: String {
        String(
            localized: "subscription.error.receipt_in_use",
            defaultValue: "This receipt is already in use by another account."
        )
    }

    public static var errorPaymentPending: String {
        String(
            localized: "subscription.error.payment_pending",
            defaultValue: "Your payment is pending approval. You will get access once approved."
        )
    }

    // MARK: - Store Names

    public static var storeAppStore: String {
        String(
            localized: "subscription.store.app_store",
            defaultValue: "App Store"
        )
    }

    public static var storeMacAppStore: String {
        String(
            localized: "subscription.store.mac_app_store",
            defaultValue: "Mac App Store"
        )
    }

    public static var storePlayStore: String {
        String(
            localized: "subscription.store.play_store",
            defaultValue: "Play Store"
        )
    }

    public static var storeStripe: String {
        String(
            localized: "subscription.store.stripe",
            defaultValue: "Web"
        )
    }

    public static var storePromotional: String {
        String(
            localized: "subscription.store.promotional",
            defaultValue: "Promotional"
        )
    }
}
