import ConcurrencyExtras
import SettingsRepository
import XCTest

final class SettingsRepositoryTests: XCTestCase {
    
    func testMutation_nonOptional() {
        let repository = SettingsRepository(store: .inMemory)
        
        let key = SettingKey("key", defaultValue: 0)
        XCTAssertEqual(repository[key], 0)
        
        repository[key] = 42
        XCTAssertEqual(repository[key], 42)
        
        repository.resetValue(forKey: key)
        XCTAssertEqual(repository[key], 0)
    }
    
    func testMutation_optional_defaultNil() {
        let repository = SettingsRepository(store: .inMemory)
        
        let key = SettingKey<String?>("key")
        XCTAssertEqual(repository[key], nil)
        
        repository[key] = "foo"
        XCTAssertEqual(repository[key], "foo")
        
        repository[key] = nil
        XCTAssertEqual(repository[key], nil)
    }
    
    func testMutation_optional_defaultNonNil() {
        let repository = SettingsRepository(store: .inMemory)
        
        let key = SettingKey<String?>("key", defaultValue: "bar")
        XCTAssertEqual(repository[key], "bar")
        
        repository[key] = "foo"
        XCTAssertEqual(repository[key], "foo")
        
        repository[key] = nil
        XCTAssertEqual(repository[key], "bar")
    }
    
    func testObservation_nonOptional_initialSent() {
        let observedValues = LockIsolated<[Int]>([])
        
        let repository = SettingsRepository(store: .inMemory)
        
        let key = SettingKey("key", defaultValue: 0)
        let token = repository.observeValue(
            forKey: key,
            initial: true,
            handler: { value in
                observedValues.withValue({ $0.append(value) })
            }
        )
        XCTAssertEqual(observedValues.value, [0])
        
        repository[key] = 1
        XCTAssertEqual(repository[key], 1)
        XCTAssertEqual(observedValues.value, [0, 1])
        
        repository.resetValue(forKey: key)
        XCTAssertEqual(repository[key], 0)
        XCTAssertEqual(observedValues.value, [0, 1, 0])
        
        repository[key] = 2
        XCTAssertEqual(repository[key], 2)
        XCTAssertEqual(observedValues.value, [0, 1, 0, 2])
        
        repository[key] = 2
        XCTAssertEqual(repository[key], 2)
        XCTAssertEqual(observedValues.value, [0, 1, 0, 2, 2])
        
        token.cancel()
        
        repository[key] = 3
        XCTAssertEqual(repository[key], 3)
        XCTAssertEqual(observedValues.value, [0, 1, 0, 2, 2])
    }
    
    func testObservation_optional_initialNotSent() {
        let observedValues = LockIsolated<[Int?]>([])
        
        let repository = SettingsRepository(store: .inMemory)
        
        let key = SettingKey<Int?>("key")
        let token = repository.observeValue(
            forKey: key,
            initial: false,
            handler: { value in
                observedValues.withValue({ $0.append(value) })
            }
        )
        XCTAssertEqual(observedValues.value, [])
        
        repository[key] = 1
        XCTAssertEqual(repository[key], 1)
        XCTAssertEqual(observedValues.value, [1])
        
        repository[key] = nil
        XCTAssertEqual(repository[key], nil)
        XCTAssertEqual(observedValues.value, [1, nil])
        
        repository[key] = 2
        XCTAssertEqual(repository[key], 2)
        XCTAssertEqual(observedValues.value, [1, nil, 2])
        
        repository[key] = 2
        XCTAssertEqual(repository[key], 2)
        XCTAssertEqual(observedValues.value, [1, nil, 2, 2])
        
        token.cancel()
        
        repository[key] = 3
        XCTAssertEqual(repository[key], 3)
        XCTAssertEqual(observedValues.value, [1, nil, 2, 2])
    }
    
    func testObservation_tokenDeinit() {
        let observedValues = LockIsolated<[Int?]>([])
        
        let repository = SettingsRepository(store: .inMemory)
        
        let key = SettingKey<Int?>("key")
        var token: SettingValueObservationToken? = repository.observeValue(
            forKey: key,
            initial: false,
            handler: { value in
                observedValues.withValue({ $0.append(value) })
            }
        )
        
        repository[key] = 1
        XCTAssertEqual(repository[key], 1)
        XCTAssertEqual(observedValues.value, [1])
        
        _ = token
        token = nil
        
        repository[key] = 2
        XCTAssertEqual(repository[key], 2)
        XCTAssertEqual(observedValues.value, [1])
    }
    
}
