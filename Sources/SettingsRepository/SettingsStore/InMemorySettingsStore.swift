import ConcurrencyExtras
import struct Foundation.UUID

extension SettingsStore where Self == InMemorySettingsStore {
    public static var inMemory: Self { Self() }
}

/// An in-memory settings store.
public final class InMemorySettingsStore: SettingsStore {

    // ============================================================================ //
    // MARK: Initialization
    // ============================================================================ //
    
    public init() {}
    
    // ============================================================================ //
    // MARK: Accessing Settings
    // ============================================================================ //
    
    public func observeValue(
        forKey key: String,
        initial: Bool,
        handler: @escaping @Sendable (SettingValue?) -> Void
    ) -> SettingValueObservationToken {
        return self.state.withValue { state in
            // Store the observer handler.
            let id = UUID()
            state.observers[key, default: [:]][id] = handler
            
            // Immediately send current value if configured as such.
            if initial {
                handler(state.storage[key])
            }
            
            // Return a token that removes this handler when cancelled or deinitialized.
            return SettingValueObservationToken { [weak self] in
                guard let self else { return }
                self.state.withValue { state in
                    state.observers[key]?[id] = nil
                }
            }
        }
    }
    
    public func value(forKey key: String) -> SettingValue? {
        return self.state.withValue { $0.storage[key] }
    }
    
    public func setValue(
        _ newValue: SettingValue,
        forKey key: String
    ) {
        self._setValue(newValue, forKey: key)
    }
    
    public func removeValue(
        forKey key: String
    ) {
        self._setValue(nil, forKey: key)
    }
    
    private func _setValue(
        _ newValue: SettingValue?,
        forKey key: String
    ) {
        let handlers: [@Sendable (SettingValue?) -> Void] = self.state.withValue { state in
            state.storage[key] = newValue
            
            guard let handlers = state.observers[key]?.values else { return [] }
            return Array(handlers)
        }
        
        for handler in handlers {
            handler(newValue)
        }
    }
    
    // ============================================================================ //
    // MARK: State
    // ============================================================================ //
    
    private struct State {
        var storage: [String: SettingValue] = [:]
        var observers: [String: [UUID: @Sendable (SettingValue?) -> Void]] = [:]
    }
    
    private let state = LockIsolated(State())
    
}
