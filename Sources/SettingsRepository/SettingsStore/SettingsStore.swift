/// A backing low-level store for a `SettingsRepository`, storing values by string keys.
///
/// This protocol knows only about raw keys and typed values—it does not handle default values
/// or `SettingKey`s.
public protocol SettingsStore: AnyObject, Sendable {
    
    /// Observes changes to the setting value for the given key.
    ///
    /// - Parameters:
    ///   - key: The key of the setting to observe.
    ///   - initial: A flag indicating whether to send the current value immediately.
    ///   - handler: A closure that receives the updated setting value whenever it changes,
    ///     or `nil` when the value is removed. The change can originate from this store
    ///     or from external modifications.
    /// - Returns: A token that retains the observation until cancelled or deallocated.
    func observeValue(
        forKey key: String,
        initial: Bool,
        handler: @escaping @Sendable (SettingValue?) -> Void
    ) -> SettingValueObservationToken
    
    /// Retrieves the stored setting value for the given key.
    func value(forKey key: String) -> SettingValue?
    
    /// Stores the given value under the specific key.
    func setValue(
        _ newValue: SettingValue,
        forKey key: String
    )
    
    /// Removes any stored value for the given key.
    func removeValue(forKey key: String)
    
}
