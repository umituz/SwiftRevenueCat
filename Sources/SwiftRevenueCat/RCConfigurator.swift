import Foundation
import RevenueCat
import OSLog

enum RCConfigurator {

    private static let logger = Logger(subsystem: SwiftRevenueCatConstants.subsystem, category: "RCConfigurator")

    @discardableResult
    static func configure(apiKey: String?, delegate: (any PurchasesDelegate)? = nil) -> Bool {
        guard let apiKey, !apiKey.isEmpty else {
            logger.error("RevenueCat API key is missing or empty")
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
