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
        // An unresolved build-setting placeholder (e.g. "$(RC_API_KEY)") means the
        // xcconfig variable was never filled in — treat it exactly like a missing key.
        guard !key.hasPrefix("$(") else {
            logger.error("API key '\(infoPlistKey)' is an unresolved build-setting placeholder")
            return nil
        }
        return key
    }
}
