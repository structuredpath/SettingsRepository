import ConcurrencyExtras
import IssueReporting
import SettingsRepository
import XCTest

final class UserDefaultsSettingsStoreTests: XCTestCase {
    
    private func makeUserDefaults() -> UserDefaults {
        let suiteName = "eu.structuredpath.SettingsRepositoryTests.\(UUID().uuidString)"
        nonisolated(unsafe)let userDefaults = UserDefaults(suiteName: suiteName)!
        
        self.addTeardownBlock {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
        
        return userDefaults
    }
    
    func testReadWrite_boolValue() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        XCTAssertEqual(store.value(forKey: "key"), nil)
        
        store.setValue(.bool(true), forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .bool(true))
        
        userDefaults.set(false, forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .bool(false))
        
        store.removeValue(forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), nil)
    }
    
    func testReadWrite_intValue() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        XCTAssertEqual(store.value(forKey: "key"), nil)
        
        store.setValue(.int(42), forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .int(42))
        
        userDefaults.set(73, forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .int(73))
        
        store.removeValue(forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), nil)
    }
    
    func testReadWrite_doubleValue() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        XCTAssertEqual(store.value(forKey: "key"), nil)
        
        store.setValue(.double(3.14), forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .double(3.14))
        
        userDefaults.set(2.71, forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .double(2.71))
        
        store.removeValue(forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), nil)
    }
    
    func testReadWrite_stringValue() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        XCTAssertEqual(store.value(forKey: "key"), nil)
        
        store.setValue(.string("foo"), forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .string("foo"))
        
        userDefaults.set("bar", forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .string("bar"))
        
        store.removeValue(forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), nil)
    }
    
    func testReadWrite_dataValue() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        XCTAssertEqual(store.value(forKey: "key"), nil)
        
        store.setValue(.data(Data([0x01, 0x02, 0x03])), forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .data(Data([0x01, 0x02, 0x03])))
        
        userDefaults.set(Data([0xAA, 0xBB]), forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .data(Data([0xAA, 0xBB])))
        
        store.removeValue(forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), nil)
    }
    
    func testReadWrite_urlValue() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        XCTAssertEqual(store.value(forKey: "key"), nil)
        
        store.setValue(.url(URL(string: "https://example.com")!), forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .url(URL(string: "https://example.com")!))
        XCTAssertEqual(userDefaults.url(forKey: "key"), URL(string: "https://example.com")!)
        
        userDefaults.set(URL(string: "https://apple.com")!, forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .url(URL(string: "https://apple.com")!))
        XCTAssertEqual(userDefaults.url(forKey: "key"), URL(string: "https://apple.com")!)
        
        store.removeValue(forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), nil)
    }
    
    func testReadWrite_arrayValue() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        XCTAssertEqual(store.value(forKey: "key"), nil)
        
        store.setValue(.array([.int(1), .int(2), .int(3)]), forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .array([.int(1), .int(2), .int(3)]))
        
        userDefaults.set([4, 5, 6], forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .array([.int(4), .int(5), .int(6)]))
        
        store.removeValue(forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), nil)
    }
    
    func testReadWrite_dictionaryValue() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        
        let dictionary: [String: SettingValue] = [
            "a": .int(42),
            "b": .bool(false),
            "c": .string("foo")
        ]
        
        XCTAssertEqual(store.value(forKey: "key"), nil)
        
        store.setValue(.dictionary(dictionary), forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), .dictionary(dictionary))
        
        store.removeValue(forKey: "key")
        XCTAssertEqual(store.value(forKey: "key"), nil)
    }
    
    func testObservation_withInitial_unset() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        
        let observedValues = LockIsolated<[SettingValue?]>([])
        
        let token = store.observeValue(
            forKey: "key",
            initial: true
        ) { value in
            observedValues.withValue { $0.append(value) }
        }
        
        XCTAssertEqual(observedValues.value, [nil])
        
        store.setValue(.int(42), forKey: "key")
        XCTAssertEqual(observedValues.value, [nil, .int(42)])
        
        userDefaults.set(73, forKey: "key")
        XCTAssertEqual(observedValues.value, [nil, .int(42), .int(73)])
        
        store.removeValue(forKey: "key")
        XCTAssertEqual(observedValues.value, [nil, .int(42), .int(73), nil])
        
        token.cancel()
        
        store.setValue(.int(1), forKey: "key")
        XCTAssertEqual(observedValues.value, [nil, .int(42), .int(73), nil])
    }
    
    func testObservation_withInitial_set() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        
        let observedValues = LockIsolated<[SettingValue?]>([])
        
        store.setValue(.int(42), forKey: "key")
        
        let token = store.observeValue(
            forKey: "key",
            initial: true
        ) { value in
            observedValues.withValue { $0.append(value) }
        }
        
        XCTAssertEqual(observedValues.value, [.int(42)])
        
        store.setValue(.int(73), forKey: "key")
        XCTAssertEqual(observedValues.value, [.int(42), .int(73)])
        
        _ = token
    }
    
    func testObservation_withoutInitial() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        
        let observedValues = LockIsolated<[SettingValue?]>([])
        
        var token: SettingValueObservationToken? = store.observeValue(
            forKey: "key",
            initial: false
        ) { value in
            observedValues.withValue { $0.append(value) }
        }
        
        XCTAssertEqual(observedValues.value, [])
        
        store.setValue(.int(42), forKey: "key")
        XCTAssertEqual(observedValues.value, [.int(42)])
        
        userDefaults.set(73, forKey: "key")
        XCTAssertEqual(observedValues.value, [.int(42), .int(73)])
        
        store.removeValue(forKey: "key")
        XCTAssertEqual(observedValues.value, [.int(42), .int(73), nil])
        
        _ = token
        token = nil
        
        store.setValue(.int(1), forKey: "key")
        XCTAssertEqual(observedValues.value, [.int(42), .int(73), nil])
    }
    
    func testInvalidKeys() {
        let userDefaults = self.makeUserDefaults()
        let store = UserDefaultsSettingsStore(userDefaults: userDefaults)
        
        XCTExpectFailure {
            _ = store.observeValue(
                forKey: "foo.bar",
                initial: false,
                handler: { _ in }
            )
        } issueMatcher: { issue in
            ["“foo.bar”", "“.”"].allSatisfy {
                issue.compactDescription.contains($0)
            }
        }
        
        XCTExpectFailure {
            _ = store.observeValue(
                forKey: "foo@bar",
                initial: false,
                handler: { _ in }
            )
        } issueMatcher: { issue in
            ["“foo@bar”", "“@”"].allSatisfy {
                issue.compactDescription.contains($0)
            }
        }
    }
    
}
