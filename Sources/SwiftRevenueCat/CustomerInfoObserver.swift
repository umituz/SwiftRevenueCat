import Foundation
import RevenueCat
import OSLog

@MainActor
public final class CustomerInfoObserver {
    private let logger = Logger(subsystem: "SwiftRevenueCat", category: "CustomerInfoObserver")
    private var streamTask: Task<Void, Never>?
    private let updateHandler: (CustomerInfo) -> Void

    public init(updateHandler: @escaping (CustomerInfo) -> Void) {
        self.updateHandler = updateHandler
    }

    public func start() {
        cancel()

        streamTask = Task { [weak self] in
            guard let self else { return }

            for await info in Purchases.shared.customerInfoStream {
                guard !Task.isCancelled else { break }
                self.logger.info("New CustomerInfo received from stream")
                self.updateHandler(info)
            }
        }

        logger.info("CustomerInfoObserver started")
    }

    public func cancel() {
        streamTask?.cancel()
        streamTask = nil
    }

    deinit {
        streamTask?.cancel()
    }
}
