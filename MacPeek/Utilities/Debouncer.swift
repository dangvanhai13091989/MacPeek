import Foundation

/// A thread-safe debouncer that delays execution of a block.
/// If called again before the delay expires, the previous call is cancelled.
final class Debouncer {

    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue

    /// Initialize with a delay in seconds.
    /// - Parameters:
    ///   - delay: Time in seconds to wait before executing. Default is 0.3 (300ms).
    ///   - queue: The dispatch queue to execute the block on. Default is main.
    init(delay: TimeInterval = 0.3, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    /// Schedule a block to execute after the debounce delay.
    /// Cancels any previously scheduled block.
    func debounce(action: @escaping () -> Void) {
        // Cancel the previous work item
        workItem?.cancel()

        // Create a new work item
        let item = DispatchWorkItem(block: action)
        workItem = item

        // Schedule execution after the delay
        queue.asyncAfter(deadline: .now() + delay, execute: item)
    }

    /// Cancel any pending debounced action.
    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
