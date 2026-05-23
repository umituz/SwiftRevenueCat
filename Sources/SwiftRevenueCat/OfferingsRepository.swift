import Foundation
import RevenueCat
import OSLog

@MainActor
final class OfferingsRepository {
    private let logger = Logger(subsystem: "SwiftRevenueCat", category: "OfferingsRepository")
    private var fetchTask: Task<Offerings?, Never>?
    private static let retryDelaySeconds: UInt64 = 2
    private static var retryDelayNanoseconds: UInt64 { retryDelaySeconds * 1_000_000_000 }

    init() {}

    func fetch() async -> Offerings? {
        if let existingTask = fetchTask {
            return await existingTask.value
        }

        let task = Task<Offerings?, Never> { [weak self] in
            defer { self?.fetchTask = nil }

            do {
                let offerings = try await Purchases.shared.offerings()
                self?.logger.info("Offerings fetched successfully")
                return offerings
            } catch {
                self?.logger.error("Offerings fetch failed: \(error.localizedDescription)")

                do {
                    try await Task.sleep(nanoseconds: Self.retryDelayNanoseconds)
                } catch {
                    self?.logger.info("Offerings retry cancelled")
                    return nil
                }

                do {
                    let retried = try await Purchases.shared.offerings()
                    self?.logger.info("Offerings fetch retry succeeded")
                    return retried
                } catch {
                    self?.logger.error("Offerings fetch retry also failed: \(error.localizedDescription)")
                    return nil
                }
            }
        }

        fetchTask = task
        return await task.value
    }
}
