import IssueReporting

public final class SettingsRepository: Sendable {
    
    // ============================================================================ //
    // MARK: Initialization
    // ============================================================================ //
    
    public init(store: SettingsStore) {
        self.store = store
    }
    
    // ============================================================================ //
    // MARK: Configuration
    // ============================================================================ //
    
    /// The underlying settings store.
    private let store: SettingsStore
    
    // ============================================================================ //
    // MARK: Accessing Setting Values
    // ============================================================================ //
    
    /// Accesses the setting value associated with the given setting key for reading and writing.
    public subscript<Value: SettingValueConvertible>(
        _ key: SettingKey<Value>
    ) -> Value {
        get {
            if let rawValue = self.store.value(forKey: key.rawKey) {
                do {
                    return try Value(from: rawValue)
                } catch {
                    reportIssue(error)
                }
            }
            
            return key.defaultValue
        }
        set {
            self.store.setValue(
                newValue.toSettingValue(),
                forKey: key.rawKey
            )
        }
    }
    
    /// Accesses the optional setting value associated with the given setting key for reading
    /// and writing.
    public subscript<Value>(
        _ key: SettingKey<Value>
    ) -> Value.Wrapped? where Value: OptionalType, Value.Wrapped: SettingValueConvertible {
        get {
            if let rawValue = self.store.value(forKey: key.rawKey) {
                do {
                    return try Value.Wrapped(from: rawValue)
                } catch {
                    reportIssue(error)
                }
            }
            
            return key.defaultValue.asOptional
        }
        set {
            if let newValue {
                self.store.setValue(
                    newValue.toSettingValue(),
                    forKey: key.rawKey
                )
            } else {
                self.store.removeValue(forKey: key.rawKey)
            }
        }
    }
    
    // ============================================================================ //
    // MARK: Resetting Setting Values
    // ============================================================================ //
    
    public func resetValue<Value: SettingValueConvertible>(
        forKey key: SettingKey<Value>
    ) {
        self.store.removeValue(forKey: key.rawKey)
    }
    
    public func resetValue<Value>(
        forKey key: SettingKey<Value>
    ) where Value: OptionalType, Value.Wrapped: SettingValueConvertible {
        self.store.removeValue(forKey: key.rawKey)
    }
    
    // ============================================================================
    // MARK: Observing Setting Values
    // ============================================================================
    
    public func observeValue<Value: SettingValueConvertible>(
        forKey key: SettingKey<Value>,
        initial: Bool,
        handler: @escaping @Sendable (Value) -> Void
    ) -> SettingValueObservationToken {
        return self.store.observeValue(
            forKey: key.rawKey,
            initial: initial
        ) { rawValue in
            let output: Value = {
                if let rawValue {
                    do {
                        return try Value(from: rawValue)
                    } catch {
                        reportIssue(error)
                    }
                }
                return key.defaultValue
            }()
            
            handler(output)
        }
    }
    
    public func observeValue<Value>(
        forKey key: SettingKey<Value>,
        initial: Bool,
        handler: @escaping @Sendable (Value.Wrapped?) -> Void
    ) -> SettingValueObservationToken where Value: OptionalType, Value.Wrapped: SettingValueConvertible {
        return self.store.observeValue(
            forKey: key.rawKey,
            initial: initial
        ) { rawValue in
            let output: Value.Wrapped? = {
                if let rawValue {
                    do {
                        return try Value.Wrapped(from: rawValue)
                    } catch {
                        reportIssue(error)
                    }
                }
                return key.defaultValue.asOptional
            }()
            
            handler(output)
        }
    }
    
}
