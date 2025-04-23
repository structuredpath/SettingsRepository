import ConcurrencyExtras

/// A token representing an active setting value observation.
///
/// Retains the observation for its lifetime, or until `cancel()` is called.
public final class SettingValueObservationToken: Sendable {
    
    internal init(_ onCancel: @Sendable @escaping () -> Void) {
        self.onCancel = LockIsolated(onCancel)
    }
    
    private let onCancel: LockIsolated<(@Sendable () -> Void)?>

    /// Cancels the observation.
    public func cancel() {
        self.onCancel.withValue { onCancel in
            onCancel?()
            onCancel = nil
        }
    }
    
    deinit {
        self.cancel()
    }
    
}
