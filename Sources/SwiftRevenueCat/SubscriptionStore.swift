import Foundation
import RevenueCat
import OSLog

// NSObject required: PurchasesDelegate extends NSObjectProtocol
@MainActor
public final class SubscriptionStore: NSObject,
    ObservableObject,
    SubscriptionStateProviding,
    OfferingsProviding,
    PurchaseProviding,
    PurchasesDelegate {

    public struct Configuration {
        public let apiKeyInfoPlistKey: String
        public let subscriptionCacheKey: String
        public let manageSubscriptionsURL: URL
        public let entitlementId: String?

        private static let defaultManageSubscriptionsURL: URL = {
            let urlString = "https://apps.apple.com/account/subscriptions"
            guard let url = URL(string: urlString) else {
                assertionFailure("Hardcoded URL is invalid — this is a compile-time constant")
                // Fallback to a URL that is guaranteed to be valid
                return URL(string: "https://apple.com") ?? URL(fileURLWithPath: "/dev/null")
            }
            return url
        }()

        public init(
            apiKeyInfoPlistKey: String = "RCApiKey",
            subscriptionCacheKey: String = "subscription_status_cache",
            manageSubscriptionsURL: URL? = nil,
            entitlementId: String? = nil
        ) {
            self.apiKeyInfoPlistKey = apiKeyInfoPlistKey
            self.subscriptionCacheKey = subscriptionCacheKey
            self.manageSubscriptionsURL = manageSubscriptionsURL ?? Self.defaultManageSubscriptionsURL
            self.entitlementId = entitlementId
        }
    }

    public static let shared = SubscriptionStore()

    @Published public private(set) var isSubscribed: Bool = false
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var offerings: Offerings?
    @Published public private(set) var plans: [Plan] = []
    @Published public private(set) var customerInfo: CustomerInfo?
    @Published public private(set) var hasVerifiedWithServer: Bool = false
    @Published public private(set) var display: SubscriptionDisplayModel = .empty
    @Published public private(set) var configurationError: SubscriptionError?

    public var onStatusChanged: (@Sendable (Bool, CustomerInfo?) -> Void)?

    public var activePlan: Plan? {
        guard let entitlement = EntitlementResolver.activeEntitlement(
            from: customerInfo,
            entitlementId: config?.entitlementId
        ) else { return nil }
        return plans.first {
            $0.revenueCatPackage.storeProduct.productIdentifier == entitlement.productIdentifier
        }
    }

    internal let logger = Logger(subsystem: SwiftRevenueCatConstants.subsystem, category: "SubscriptionStore")
    internal let offeringsRepo = OfferingsRepository()
    internal let executor = PurchaseExecutor()
    private var observer: CustomerInfoObserver?
    private var refreshTask: Task<Void, Never>?
    /// True after a successful `configure(with:)` — the RevenueCat SDK is
    /// initialized and purchase/restore calls may proceed.
    public private(set) var isConfigured = false
    internal var config: Configuration?

    private override init() {
        super.init()
    }

    // MARK: - Configuration

    public func configure(with config: Configuration = Configuration()) {
        guard !isConfigured else {
            logger.warning("SubscriptionStore already configured - ignoring duplicate call")
            return
        }
        self.config = config

        SubscriptionCache.configure(cacheKey: config.subscriptionCacheKey)

        let apiKey = SubscriptionAPIKeyProvider.apiKey(from: config.apiKeyInfoPlistKey)
        let success = RCConfigurator.configure(apiKey: apiKey, delegate: self)
        guard success else {
            configurationError = .apiKeyMissing
            logger.error("RevenueCat configuration failed - API key missing")
            return
        }

        isConfigured = true
        configurationError = nil

        restoreFromCacheIfAvailable()

        observer = CustomerInfoObserver { [weak self] info in
            self?.applyCustomerInfo(info)
        }
        observer?.start()
        refreshTask = Task { [weak self] in
            await self?.refreshStatus()
        }
    }

    public func reset() {
        refreshTask?.cancel()
        refreshTask = nil
        observer?.cancel()
        observer = nil
        customerInfo = nil
        isSubscribed = false
        isLoading = false
        offerings = nil
        plans = []
        hasVerifiedWithServer = false
        display = .empty
        configurationError = nil
        isConfigured = false
        config = nil
        SubscriptionCache.clear()
        SubscriptionCache.resetCacheKey()

        if Purchases.isConfigured {
            Purchases.shared.invalidateCustomerInfoCache()
        }
        logger.info("SubscriptionStore reset")
    }

    // MARK: - CustomerInfo Application

    func applyCustomerInfo(_ info: CustomerInfo) {
        let entitlement = EntitlementResolver.activeEntitlement(
            from: info,
            entitlementId: config?.entitlementId
        )
        let subscribed = entitlement != nil
        self.customerInfo = info
        self.isSubscribed = subscribed
        self.hasVerifiedWithServer = true

        SubscriptionCache.save(isSubscribed: subscribed, expirationDate: entitlement?.expirationDate)

        updateDisplay()
        logSubscriptionUpdate(subscribed: subscribed, productIdentifier: entitlement?.productIdentifier)
        onStatusChanged?(subscribed, info)
    }

    func updateDisplay() {
        self.display = SubscriptionDisplayMapper.map(
            customerInfo: customerInfo,
            offerings: offerings,
            entitlementId: config?.entitlementId
        )
    }

    // MARK: - Status

    public func getStatus() -> SubscriptionStatus {
        let activeEntitlement = EntitlementResolver.activeEntitlement(
            from: customerInfo,
            entitlementId: config?.entitlementId
        )
        return SubscriptionStatus(
            isSubscribed: isSubscribed,
            expirationDate: activeEntitlement?.expirationDate,
            isActive: isSubscriptionActive()
        )
    }

    public var relativeExpirationDate: String? {
        guard let date = getExpirationDate() else { return nil }
        return SubscriptionContentResolver.relativeDateString(from: date)
    }

    // MARK: - Internal Setters

    private func restoreFromCacheIfAvailable() {
        guard SubscriptionCache.loadSubscribedStatus() else { return }
        isSubscribed = true
        logger.info("Restored subscribed status from offline cache")
    }

    func setLoading(_ value: Bool) { isLoading = value }

    func guardIsConfigured(_ operation: StaticString) -> Bool {
        guard Purchases.isConfigured else {
            logger.warning("Purchases is not configured yet. Skipping \(operation).")
            return false
        }
        return true
    }

    func updateOfferings(_ value: Offerings?) {
        offerings = value
        plans = PlanMapper.mapPlans(from: value)
    }

    // MARK: - Logging

    private func logSubscriptionUpdate(subscribed: Bool, productIdentifier: String?) {
        let status: String
        if subscribed {
            status = "SUBSCRIBED"
        } else {
            status = "FREE"
        }
        let product = productIdentifier ?? "none"
        logger.info("Subscription updated: \(status), entitlement: \(product)")
    }

    // MARK: - PurchasesDelegate

    nonisolated public func purchases(
        _ purchases: Purchases,
        shouldPurchasePromoProduct product: StoreProduct
    ) -> Bool { true }
}
