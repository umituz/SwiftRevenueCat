import Foundation
import RevenueCat
import OSLog

@MainActor
final class OfferingsRepository {
    private let logger = Logger(subsystem: SwiftRevenueCatConstants.subsystem, category: "OfferingsRepository")
    private var fetchTask: Task<Offerings?, Never>?

    private static let initialRetryDelay: UInt64 = 1_000_000_000
    private static let maxRetryDelay: UInt64 = 8_000_000_000
    private static let maxRetryCount = 2

    init() {}

    func fetch() async -> Offerings? {
        if let existingTask = fetchTask {
            return await existingTask.value
        }

        let task = Task<Offerings?, Never> { [weak self] in
            defer { self?.fetchTask = nil }
            return await self?.performFetchWithRetry()
        }

        fetchTask = task
        return await task.value
    }

    private func performFetchWithRetry() async -> Offerings? {
        var currentDelay = Self.initialRetryDelay

        for attempt in 0...Self.maxRetryCount {
            do {
                let offerings = try await Purchases.shared.offerings()
                logger.info("Offerings fetched successfully on attempt \(attempt + 1)")
                return offerings
            } catch {
                if attempt < Self.maxRetryCount {
                    let delaySeconds = currentDelay / 1_000_000_000
                    logger.warning("""
                    Offerings fetch attempt \(attempt + 1) failed: \
                    \(error.localizedDescription). Retrying in \(delaySeconds)s
                    """)

                    do {
                        try await Task.sleep(nanoseconds: currentDelay)
                    } catch {
                        logger.info("Offerings retry sleep cancelled")
                        return nil
                    }

                    currentDelay = min(currentDelay * 2, Self.maxRetryDelay)
                } else {
                    let totalAttempts = Self.maxRetryCount + 1
                    logger.error("""
                    Offerings fetch failed after \(totalAttempts) attempts: \
                    \(error.localizedDescription)
                    """)
                    return nil
                }
            }
        }

        return nil
    }
}
