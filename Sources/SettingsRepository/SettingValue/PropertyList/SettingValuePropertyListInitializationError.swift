public enum SettingValuePropertyListInitializationError: Error {
    
    /// The property list is malformed or contains unsupported structures.
    case malformedPropertyList
    
    /// The property list includes a number type with an unsupported encoding.
    case unsupportedNumberTypeEncoding(String)
    
}
