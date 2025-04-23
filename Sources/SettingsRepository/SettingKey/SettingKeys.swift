/// A namespace for grouping `SettingKey` definitions.
///
/// Extend this class to declare your application’s settings keys, for example:
///
/// ```swift
/// extension SettingKeys {
///     static let theme = SettingKey<String?>("Theme")
///     static let notificationsEnabled = SettingKey("NotificationsEnabled", defaultValue: true)
/// }
/// ```
public class SettingKeys: @unchecked Sendable {}
