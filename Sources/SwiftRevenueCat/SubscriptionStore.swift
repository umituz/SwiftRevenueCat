import Foundation
import RevenueCat
import OSLog

@MainActor
public final class SubscriptionStore: NSObject, ObservableObject, SubscriptionStateProviding, OfferingsProviding, PurchaseProviding, PurchasesDelegate {

    public struct Configuration {
        public let apiKeyInfoPlistKey: String
        public let proStatusCacheKey: String
        public let manageSubscriptionsURL: String

        public init(
            apiKeyInfoPlistKey: String = "RCApiKey",
            proStatusCacheKey: String = "pro_status_cache",
            manageSubscriptionsURL: String = "https://apps.apple.com/account/subscriptions"
        ) {
            self.apiKeyInfoPlistKey = apiKeyInfoPlistKey
            self.proStatusCacheKey = proStatusCacheKey
            self.manageSubscriptionsURL = manageSubscriptionsURL
        }
    }

    public static let shared = SubscriptionStore()

    @Published public private(set) var isPro: Bool = false
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var offerings: Offerings?
    @Published public private(set) var customerInfo: CustomerInfo?
    @Published public private(set) var hasVerifiedWithServer: Bool = false
    @Published public private(set) var display: SubscriptionDisplayModel = .empty

    public var onStatusChanged: ((Bool, CustomerInfo?) -> Void)?

    private let logger = Logger(subsystem: "SwiftRevenueCat", category: "SubscriptionStore")
    private let offeringsRepo = OfferingsRepository()
    private let executor = PurchaseExecutor()
    private var observer: CustomerInfoObserver?
    private var isConfigured = false
    private var config: Configuration?

    internal func getConfig() -> Configuration? { config }

    private override init() {
        super.init()
        self.isPro = false
        self.display = .empty
    }

    public func configure(with config: Configuration = Configuration()) {
        guard !isConfigured else { return }
        self.config = config

        ProStatusCache.configure(cacheKey: config.proStatusCacheKey)

        let apiKey = SubscriptionAPIKeyProvider.apiKey(from: config.apiKeyInfoPlistKey)
        let success = RCConfigurator.configure(apiKey: apiKey, delegate: self)
        guard success else {
            logger.error("RevenueCat configuration failed - API key missing")
            return
        }

        isConfigured = true
        observer = CustomerInfoObserver { [weak self] info in self?.applyCustomerInfo(info) }
        observer?.start()
        Task { await refreshStatus() }
    }

    internal func applyCustomerInfo(_ info: CustomerInfo) {
        let entitlement = EntitlementResolver.activeEntitlement(from: info)
        let proActive = entitlement != nil
        self.customerInfo = info
        self.isPro = proActive
        self.hasVerifiedWithServer = true

        ProStatusCache.save(isPro: proActive, expirationDate: entitlement?.expirationDate)

        updateDisplay()
        logger.info("Subscription updated: \(proActive ? "PRO" : "FREE"), entitlement: \(entitlement?.productIdentifier ?? "none")")

        onStatusChanged?(proActive, info)
    }

    internal func updateDisplay() {
        self.display = SubscriptionDisplayMapper.map(customerInfo: customerInfo, offerings: offerings)
    }

    public func getStatus() -> SubscriptionStatus {
        SubscriptionStatus(
            isPro: isPro,
            expirationDate: EntitlementResolver.activeEntitlement(from: customerInfo)?.expirationDate,
            isActive: isPro
        )
    }

    // MARK: - Internal Accessors

    internal func getLogger() -> Logger { logger }
    internal func getOfferingsRepo() -> OfferingsRepository { offeringsRepo }
    internal func getExecutor() -> PurchaseExecutor { executor }
    internal func setIsLoading(_ value: Bool) { isLoading = value }
    internal func setOfferings(_ value: Offerings?) { offerings = value }

    // MARK: - PurchasesDelegate

    nonisolated public func purchases(_ purchases: Purchases, shouldPurchasePromoProduct product: StoreProduct) -> Bool { true }
}
