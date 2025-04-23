import IssueReporting
import Foundation

extension SettingsStore where Self == UserDefaultsSettingsStore {

    /// A settings store backed by a `UserDefaults` instance.
    public static func userDefaults(_ userDefaults: UserDefaults) -> Self {
        Self(userDefaults: userDefaults)
    }
    
}

/// A settings store backed by a `UserDefaults` instance.
public final class UserDefaultsSettingsStore: SettingsStore {
    
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public nonisolated(unsafe) let userDefaults: UserDefaults
    
    public func observeValue(
        forKey key: String,
        initial: Bool,
        handler: @escaping @Sendable (SettingValue?) -> Void
    ) -> SettingValueObservationToken {
        let invalidCharacter: String? = {
            if key.contains(".") { return "." }
            if key.contains("@") { return "@" }
            return nil
        }()
        
        if let invalidCharacter {
            withIssueReporters([.fatalError]) {
                reportIssue("""
                The UserDefaults key “\(key)” contains an invalid character “\(invalidCharacter)” \
                which prevents KVO observation. Please rename this key to remove the invalid character \
                before observing.
                """)
            }
        }
        
        let observer = UserDefaultsKeyValueObserver { newPropertyList in
            do {
                let newValue = try newPropertyList.flatMap {
                    try SettingValue(propertyList: $0)
                }
                
                handler(newValue)
            } catch {
                reportIssue(error)
            }
        }
        
        let options: NSKeyValueObservingOptions = initial ? [.initial, .new] : [.new]
        
        self.userDefaults.addObserver(
            observer,
            forKeyPath: key,
            options: options,
            context: nil
        )
        
        return SettingValueObservationToken { [weak self] in
            guard let self else { return }
            self.userDefaults.removeObserver(observer, forKeyPath: key)
        }
    }
    
    public func value(forKey key: String) -> SettingValue? {
        do {
            guard let propertyList = self.userDefaults.value(forKey: key) else { return nil }
            return try SettingValue(propertyList: propertyList)
        } catch {
            reportIssue(error)
            return nil
        }
    }
    
    public func setValue(_ newValue: SettingValue, forKey key: String) {
        self.userDefaults.set(
            newValue.propertyList,
            forKey: key
        )
    }
    
    public func removeValue(forKey key: String) {
        self.userDefaults.set(nil, forKey: key)
    }
    
}

// https://gist.github.com/ole/fc5c1f4c763d28d9ba70940512e81916
fileprivate final class UserDefaultsKeyValueObserver: NSObject, Sendable {
    
    fileprivate init(onChange: @escaping @Sendable (Any?) -> Void) {
        self.onChange = onChange
    }
    
    private let onChange: @Sendable (Any?) -> Void
    
    fileprivate override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let newValue = change?[.newKey] else { return }
        
        if newValue is NSNull {
            self.onChange(nil)
        } else {
            self.onChange(newValue)
        }
    }
    
}
