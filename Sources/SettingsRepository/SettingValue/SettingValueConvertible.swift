import struct Foundation.Data
import struct Foundation.URL

/// A type that can be converted to and from a `SettingValue`.
public protocol SettingValueConvertible {
    
    /// Decodes itself from a setting value.
    ///
    /// The implementation assumes a certain structure of the value. If this assumption is wrong
    /// due to a type mismatch, missing key, or other issue, an appropriate
    /// `SettingValueDecodingError` is thrown.
    init(from settingValue: SettingValue) throws(SettingValueDecodingError)
    
    /// Encodes itself into a setting value.
    func toSettingValue() -> SettingValue
    
}

extension Bool: SettingValueConvertible {
    
    public init(from settingValue: SettingValue) throws(SettingValueDecodingError) {
        switch settingValue {
        case .bool(let bool):
            self = bool
        default:
            throw .typeMismatch(
                expected: .bool,
                actual: settingValue.type
            )
        }
    }
    
    public func toSettingValue() -> SettingValue {
        .bool(self)
    }
    
}

extension Int: SettingValueConvertible {
    
    public init(from settingValue: SettingValue) throws(SettingValueDecodingError) {
        switch settingValue {
        case .int(let int):
            self = int
        default:
            throw .typeMismatch(
                expected: .int,
                actual: settingValue.type
            )
        }
    }
    
    public func toSettingValue() -> SettingValue {
        .int(self)
    }
    
}

extension Double: SettingValueConvertible {
    
    public init(from settingValue: SettingValue) throws(SettingValueDecodingError) {
        switch settingValue {
        case .double(let double):
            self = double
        default:
            throw .typeMismatch(
                expected: .double,
                actual: settingValue.type
            )
        }
    }
    
    public func toSettingValue() -> SettingValue {
        .double(self)
    }
    
}

extension String: SettingValueConvertible {
    
    public init(from settingValue: SettingValue) throws(SettingValueDecodingError) {
        switch settingValue {
        case .string(let string):
            self = string
        default:
            throw .typeMismatch(
                expected: .string,
                actual: settingValue.type
            )
        }
    }
    
    public func toSettingValue() -> SettingValue {
        .string(self)
    }
    
}

extension Data: SettingValueConvertible {
    
    public init(from settingValue: SettingValue) throws(SettingValueDecodingError) {
        switch settingValue {
        case .data(let data):
            self = data
        default:
            throw .typeMismatch(
                expected: .data,
                actual: settingValue.type
            )
        }
    }
    
    public func toSettingValue() -> SettingValue {
        .data(self)
    }
    
}

extension URL: SettingValueConvertible {
    
    public init(from settingValue: SettingValue) throws(SettingValueDecodingError) {
        switch settingValue {
        case .url(let url):
            self = url
        default:
            throw .typeMismatch(
                expected: .url,
                actual: settingValue.type
            )
        }
    }
    
    public func toSettingValue() -> SettingValue {
        .url(self)
    }
    
}

extension RawRepresentable where Self: SettingValueConvertible, RawValue: SettingValueConvertible {
    
    public init(from settingValue: SettingValue) throws(SettingValueDecodingError) {
        let rawValue = try RawValue(from: settingValue)
        
        guard let value = Self(rawValue: rawValue) else {
            throw .invalidRawValue(
                value: settingValue,
                type: Self.self
            )
        }
        
        self = value
    }
    
    public func toSettingValue() -> SettingValue {
        self.rawValue.toSettingValue()
    }
    
}
