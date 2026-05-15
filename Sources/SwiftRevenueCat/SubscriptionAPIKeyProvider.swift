import Foundation
import OSLog

public enum SubscriptionAPIKeyProvider {

    public static func apiKey(from InfoPlistKey: String = "RCApiKey") -> String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: InfoPlistKey) as? String, !key.isEmpty else {
            Logger(subsystem: "SwiftRevenueCat", category: "APIKeyProvider")
                .error("API key '\(InfoPlistKey)' is missing in Info.plist")
            return ""
        }
        return key
    }
}
