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
        public let proStatusCacheKey: String
        public let manageSubscriptionsURL: String
        public let entitlementId: String?

        public init(
            apiKeyInfoPlistKey: String = "RCApiKey",
            proStatusCacheKey: String = "pro_status_cache",
            manageSubscriptionsURL: String = "https://apps.apple.com/account/subscriptions",
            entitlementId: String? = nil
        ) {
            self.apiKeyInfoPlistKey = apiKeyInfoPlistKey
            self.proStatusCacheKey = proStatusCacheKey
            self.manageSubscriptionsURL = manageSubscriptionsURL
            self.entitlementId = entitlementId
        }
    }

    public static let shared = SubscriptionStore()

    @Published public private(set) var isPro: Bool = false
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var offerings: Offerings?
    @Published public private(set) var plans: [Plan] = []
    @Published public private(set) var customerInfo: CustomerInfo?
    @Published public private(set) var hasVerifiedWithServer: Bool = false
    @Published public private(set) var display: SubscriptionDisplayModel = .empty
    @Published public private(set) var configurationError: SubscriptionError?

    public var onStatusChanged: ((Bool, CustomerInfo?) -> Void)?

    public var activePlan: Plan? {
        guard let entitlement = EntitlementResolver.activeEntitlement(
            from: customerInfo,
            entitlementId: config?.entitlementId
        ) else { return nil }
        return plans.first {
            $0.package?.storeProduct.productIdentifier == entitlement.productIdentifier
        }
    }

    // Internal access required for extensions in SubscriptionStore+Fetch/Purchase
    let logger = Logger(subsystem: "SwiftRevenueCat", category: "SubscriptionStore")
    let offeringsRepo = OfferingsRepository()
    let executor = PurchaseExecutor()
    private var observer: CustomerInfoObserver?
    private var isConfigured = false
    var config: Configuration?

    private override init() {
        super.init()
    }

    public func configure(with config: Configuration = Configuration()) {
        guard !isConfigured else {
            logger.warning("SubscriptionStore already configured - ignoring duplicate call")
            return
        }
        self.config = config

        ProStatusCache.configure(cacheKey: config.proStatusCacheKey)

        let apiKey = SubscriptionAPIKeyProvider.apiKey(from: config.apiKeyInfoPlistKey)
        let success = RCConfigurator.configure(apiKey: apiKey, delegate: self)
        guard success else {
            configurationError = .configurationError(
                "RevenueCat API key is missing or empty"
            )
            logger.error("RevenueCat configuration failed - API key missing")
            return
        }

        isConfigured = true
        configurationError = nil
        observer = CustomerInfoObserver { [weak self] info in
            self?.applyCustomerInfo(info)
        }
        observer?.start()
        Task { await refreshStatus() }
    }

    func applyCustomerInfo(_ info: CustomerInfo) {
        let entitlement = EntitlementResolver.activeEntitlement(
            from: info,
            entitlementId: config?.entitlementId
        )
        let proActive = entitlement != nil
        self.customerInfo = info
        self.isPro = proActive
        self.hasVerifiedWithServer = true

        ProStatusCache.save(isPro: proActive, expirationDate: entitlement?.expirationDate)

        updateDisplay()

        let status = proActive ? "PRO" : "FREE"
        let product = entitlement?.productIdentifier ?? "none"
        logger.info("Subscription updated: \(status), entitlement: \(product)")

        onStatusChanged?(proActive, info)
    }

    func updateDisplay() {
        self.display = SubscriptionDisplayMapper.map(
            customerInfo: customerInfo,
            offerings: offerings
        )
    }

    public func getStatus() -> SubscriptionStatus {
        let activeEntitlement = EntitlementResolver.activeEntitlement(
            from: customerInfo,
            entitlementId: config?.entitlementId
        )
        return SubscriptionStatus(
            isPro: isPro,
            expirationDate: activeEntitlement?.expirationDate,
            isActive: isSubscriptionActive()
        )
    }

    public var relativeExpirationDate: String? {
        guard let date = getExpirationDate() else { return nil }
        return SubscriptionContentResolver.relativeDateString(from: date)
    }

    public func reset() {
        observer?.cancel()
        observer = nil
        customerInfo = nil
        isPro = false
        isLoading = false
        offerings = nil
        plans = []
        hasVerifiedWithServer = false
        display = .empty
        configurationError = nil
        ProStatusCache.clear()
        logger.info("SubscriptionStore reset")
    }

    // MARK: - Internal Setters (for extensions across files)

    func setLoading(_ value: Bool) { isLoading = value }
    func updateOfferings(_ value: Offerings?) {
        offerings = value
        plans = PlanMapper.mapPlans(from: value)
    }

    // MARK: - PurchasesDelegate

    nonisolated public func purchases(
        _ purchases: Purchases,
        shouldPurchasePromoProduct product: StoreProduct
    ) -> Bool { true }
}
