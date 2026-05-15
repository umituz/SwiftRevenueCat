import Foundation
import RevenueCat
import OSLog

public enum RCConfigurator {

    private static let logger = Logger(subsystem: "SwiftRevenueCat", category: "RCConfigurator")

    @discardableResult
    public static func configure(apiKey: String, delegate: (any PurchasesDelegate)? = nil) -> Bool {
        guard !apiKey.isEmpty else {
            logger.error("RevenueCat API key is empty")
            return false
        }

        Purchases.configure(withAPIKey: apiKey)

        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .error
        #endif

        if let delegate {
            Purchases.shared.delegate = delegate
        }

        logger.info("RevenueCat configured successfully")
        return true
    }
}
