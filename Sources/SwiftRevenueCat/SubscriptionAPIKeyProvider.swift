import Foundation
import OSLog

enum SubscriptionAPIKeyProvider {

    private static let logger = Logger(subsystem: SwiftRevenueCatConstants.subsystem, category: "APIKeyProvider")

    static func apiKey(from infoPlistKey: String = "RCApiKey") -> String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: infoPlistKey) as? String,
              !key.isEmpty else {
            logger.error("API key '\(infoPlistKey)' is missing or empty in Info.plist")
            return nil
        }
        return key
    }
}
