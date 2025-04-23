import Foundation

extension SettingValue {
    
    /// Initializes a setting value from a property list-compatible object.
    public init(propertyList: Any) throws(SettingValuePropertyListInitializationError) {
        switch propertyList {
        case let nsNumber as NSNumber:
            // https://apple.co/2DnmKUR
            let typeEncoding = String(cString: nsNumber.objCType)
            
            switch typeEncoding {
            case "B", "c":
                self = .bool(nsNumber.boolValue)
            case "i", "s", "l", "q":
                self = .int(nsNumber.intValue)
            case "f", "d":
                self = .double(nsNumber.doubleValue)
            default:
                throw .unsupportedNumberTypeEncoding(typeEncoding)
            }
            
        case let string as String:
            self = .string(string)
            
        case let array as [Any]:
            var values = [SettingValue]()
            
            for rawValue in array {
                values.append(try SettingValue(propertyList: rawValue))
            }
            
            self = .array(values)
            
        case let data as Data:
            if let url = try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: NSURL.self,
                from: data
            ) as? URL {
                self = .url(url)
            } else {
                self = .data(data)
            }
            
        case let dictionary as [String: Any]:
            var keyedValues = [String: SettingValue]()
            
            for (key, rawValue) in dictionary {
                keyedValues[key] = try SettingValue(propertyList: rawValue)
            }
            
            self = .dictionary(keyedValues)
            
        default:
            throw .malformedPropertyList
        }
    }
    
    /// Converts the setting value to a property list-compatible object.
    public var propertyList: Any {
        switch self {
        case .bool(let bool):
            return bool
        case .int(let int):
            return int
        case .double(let double):
            return double
        case .string(let string):
            return string
        case .data(let data):
            return data
        case .url(let url):
            // https://www.jessesquires.com/blog/2021/03/26/a-better-approach-to-writing-a-userdefaults-property-wrapper/#storing-url-is-special
            return try! NSKeyedArchiver.archivedData(
                withRootObject: url as NSURL,
                requiringSecureCoding: false
            )
        case .array(let array):
            return array.map(\.propertyList)
        case .dictionary(let dictionary):
            return dictionary.mapValues(\.propertyList)
        }
    }
    
}
