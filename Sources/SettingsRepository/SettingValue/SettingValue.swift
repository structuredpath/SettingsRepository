import struct Foundation.Data
import struct Foundation.URL

public enum SettingValue: Equatable, Sendable {
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case data(Data)
    case url(URL)
    case array([SettingValue])
    case dictionary([String: SettingValue])
}

extension SettingValue {
    public var type: SettingValueType {
        switch self {
        case .bool:
            return .bool
        case .int:
            return .int
        case .double:
            return .double
        case .string:
            return .string
        case .data:
            return .data
        case .url:
            return .url
        case .array:
            return .array
        case .dictionary:
            return .dictionary
        }
    }
}

extension SettingValue: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .bool(let bool):
            return "bool(\(bool))"
        case .int(let int):
            return "int(\(int))"
        case .double(let double):
            return "double(\(double))"
        case .string(let string):
            return "string(\(string))"
        case .data(let data):
            return "data(\(data))"
        case .url(let url):
            return "url(\(url))"
        case .array(let array):
            let parts = array.map { String(describing: $0) }
            return "[\(parts.joined(separator: ", "))]"
        case .dictionary(let dictionary):
            let parts = dictionary.map { key, value in "\(key): \(value)" }
            return "[\(parts.joined(separator: ", "))]"
        }
    }
}
