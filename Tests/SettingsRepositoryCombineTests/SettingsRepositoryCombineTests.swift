import Combine
import CombineExtensions
import ConcurrencyExtras
import SettingsRepository
import SettingsRepositoryCombine
import XCTest

final class SettingsRepositoryCombineTests: XCTestCase {
    
    func testPublisher_nonOptional() {
        var observedValues = [Int]()
        
        let repository = SettingsRepository(store: .inMemory)
        let key = SettingKey("key", defaultValue: 0)
        
        let publisher = repository.publisher(forKey: key)
        let cancellable = publisher.sink { observedValues.append($0) }
        XCTAssertEqual(publisher.value, 0)
        XCTAssertEqual(observedValues, [0])
        
        repository[key] = 1
        XCTAssertEqual(publisher.value, 1)
        XCTAssertEqual(observedValues, [0, 1])
        
        repository.resetValue(forKey: key)
        XCTAssertEqual(publisher.value, 0)
        XCTAssertEqual(observedValues, [0, 1, 0])
        
        repository[key] = 2
        XCTAssertEqual(publisher.value, 2)
        XCTAssertEqual(observedValues, [0, 1, 0, 2])
        
        repository[key] = 2
        XCTAssertEqual(publisher.value, 2)
        XCTAssertEqual(observedValues, [0, 1, 0, 2, 2])
        
        cancellable.cancel()
        
        repository[key] = 3
        XCTAssertEqual(publisher.value, 3)
        XCTAssertEqual(observedValues, [0, 1, 0, 2, 2])
    }
    
    func testPublisher_optional() {
        var observedValues = [Int?]()
        
        let repository = SettingsRepository(store: .inMemory)
        let key = SettingKey<Int?>("key")
        
        let publisher = repository.publisher(forKey: key)
        let cancellable = publisher.sink { observedValues.append($0) }
        XCTAssertEqual(publisher.value, nil)
        XCTAssertEqual(observedValues, [nil])
        
        repository[key] = 1
        XCTAssertEqual(publisher.value, 1)
        XCTAssertEqual(observedValues, [nil, 1])
        
        repository[key] = nil
        XCTAssertEqual(publisher.value, nil)
        XCTAssertEqual(observedValues, [nil, 1, nil])
        
        repository[key] = 2
        XCTAssertEqual(publisher.value, 2)
        XCTAssertEqual(observedValues, [nil, 1, nil, 2])
        
        repository[key] = 2
        XCTAssertEqual(publisher.value, 2)
        XCTAssertEqual(observedValues, [nil, 1, nil, 2, 2])
        
        cancellable.cancel()
        
        repository[key] = 3
        XCTAssertEqual(publisher.value, 3)
        XCTAssertEqual(observedValues, [nil, 1, nil, 2, 2])
    }
    
    func testPublisher_observationTokenDeallocatedOnCancel() {
        let weakTokenBox = LockIsolated(WeakBox<SettingValueObservationToken>())
        
        let store = TokenTrackingStore(
            base: .inMemory,
            onObserve: { token in
                weakTokenBox.withValue { $0.value = token }
            }
        )
        let repository = SettingsRepository(store: store)
        
        XCTAssertNil(weakTokenBox.value)
        
        let cancellable = repository
            .publisher(forKey: SettingKey("key", defaultValue: 0))
            .sink { _ in }
        
        XCTAssertNotNil(weakTokenBox.value)
        
        cancellable.cancel()
        XCTAssertNil(weakTokenBox.value)
    }
    
}

fileprivate final class TokenTrackingStore<BaseStore: SettingsStore>: SettingsStore {
    
    init(
        base: BaseStore,
        onObserve: @escaping @Sendable (SettingValueObservationToken) -> Void
    ) {
        self.base = base
        self.onObserve = onObserve
    }
    
    let base: BaseStore
    let onObserve: @Sendable (SettingValueObservationToken) -> Void
    
    func observeValue(
        forKey key: String,
        initial: Bool,
        handler: @Sendable @escaping (SettingValue?) -> Void
    ) -> SettingValueObservationToken {
        let token = self.base.observeValue(
            forKey: key,
            initial: initial,
            handler: handler
        )
        self.onObserve(token)
        return token
    }
    
    func value(forKey key: String) -> SettingValue? {
        self.base.value(forKey: key)
    }
    
    func setValue(_ value: SettingValue, forKey key: String) {
        self.base.setValue(value, forKey: key)
    }
    
    func removeValue(forKey key: String) {
        self.base.removeValue(forKey: key)
    }
    
}

final class WeakBox<T: AnyObject> {
    init(_ value: T? = nil) {
        self.value = value
    }
    
    weak var value: T?
}
