/// An error that can occur when converting a `SettingValue` into a Swift type.
public enum SettingValueDecodingError: Error {
    
    /// The kind of the setting value did not match what was expected (for example, expected `.int`
    /// but found `.string`).
    case typeMismatch(expected: SettingValueType, actual: SettingValueType)

    /// A `RawRepresentable` type could not be created from the provided setting value.
    case invalidRawValue(value: SettingValue, type: Any.Type)
    
    /// A required key was missing when decoding a dictionary-backed setting value.
    case keyNotFound(String)
    
    /// Any other error encountered during decoding.
    case other(Error)
    
}
