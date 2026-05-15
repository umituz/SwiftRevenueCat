import Foundation
import OSLog

enum SubscriptionAPIKeyProvider {

    static func apiKey(from infoPlistKey: String = "RCApiKey") -> String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: infoPlistKey) as? String, !key.isEmpty else {
            Logger(subsystem: "SwiftRevenueCat", category: "APIKeyProvider")
                .error("API key '\(infoPlistKey)' is missing in Info.plist")
            return ""
        }
        return key
    }
}
