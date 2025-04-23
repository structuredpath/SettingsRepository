@preconcurrency import Combine
import CombineExtensions
import SettingsRepository

extension SettingsRepository {
    
    public func publisher<Value: SettingValueConvertible>(
        forKey key: SettingKey<Value>
    ) -> CurrentValuePublisher<Value, Never> {
        CurrentValuePublisher(
            initial: self[key],
            upstream: Deferred { [weak self] () -> AnyPublisher<Value, Never> in
                guard let self else {
                    return Empty<Value, Never>(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
                
                let subject = PassthroughSubject<Value, Never>()
                
                let token = self.observeValue(
                    forKey: key,
                    initial: false
                ) { newValue in
                    subject.send(newValue)
                }
                
                return subject
                    .handleEvents(receiveCancel: { token.cancel() })
                    .eraseToAnyPublisher()
            }
        )
    }
    
    public func publisher<Value>(
        forKey key: SettingKey<Value>
    ) -> CurrentValuePublisher<Value.Wrapped?, Never> where Value: OptionalType, Value.Wrapped: SettingValueConvertible {
        CurrentValuePublisher(
            initial: self[key],
            upstream: Deferred { [weak self] () -> AnyPublisher<Value.Wrapped?, Never> in
                guard let self else {
                    return Empty<Value.Wrapped?, Never>(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
                
                let subject = PassthroughSubject<Value.Wrapped?, Never>()
                
                let token = self.observeValue(
                    forKey: key,
                    initial: false
                ) { newValue in
                    subject.send(newValue)
                }
                
                return subject
                    .handleEvents(receiveCancel: { token.cancel() })
                    .eraseToAnyPublisher()
            }
        )
    }
    
}
