/// A marker protocol implemented by `Swift.Optional`, allowing APIs to constrain over
/// optional semantics.
public protocol OptionalType: ExpressibleByNilLiteral {
    
    /// The type of the wrapped value.
    associatedtype Wrapped
    
    /// Creates an instance that stores the given value.
    init(_ some: Wrapped)
    
    /// The value in its standard `Optional<Wrapped>` form.
    var asOptional: Wrapped? { get }
    
}

extension Optional: OptionalType {
    public var asOptional: Wrapped? { self }
}
