/// A generic key that identifies a single stored setting and its default value.
public final class SettingKey<Value: Sendable>: SettingKeys, @unchecked Sendable {
    
    // ============================================================================ //
    // MARK: Initialization
    // ============================================================================ //
    
    /// Creates a key for a non-optional setting.
    public convenience init(
        _ rawKey: String,
        defaultValue: Value
    ) where Value: SettingValueConvertible {
        self.init(rawKey: rawKey, defaultValue: defaultValue)
    }
    
    /// Creates a key for an optional setting with `nil` as its default.
    public convenience init(
        _ rawKey: String
    ) where Value: OptionalType, Value.Wrapped: SettingValueConvertible {
        self.init(rawKey: rawKey, defaultValue: nil)
    }
    
    /// Creates a key for an optional setting with a non-nil default.
    public convenience init(
        _ rawKey: String,
        defaultValue: Value.Wrapped
    ) where Value: OptionalType, Value.Wrapped: SettingValueConvertible {
        self.init(rawKey: rawKey, defaultValue: Value(defaultValue))
    }
    
    fileprivate init(rawKey: String, defaultValue: Value) {
        self.rawKey = rawKey
        self.defaultValue = defaultValue
    }
    
    // ============================================================================ //
    // MARK: - Properties
    // ============================================================================ //
    
    /// The raw string representation of this `SettingKey`.
    ///
    /// This is the string form of the key itself, used by the store to save and retrieve
    /// the setting’s value. It must be unique within the settings domain.
    public let rawKey: String
    
    /// The default value returned when no explicit value has been set.
    public let defaultValue: Value
    
}
