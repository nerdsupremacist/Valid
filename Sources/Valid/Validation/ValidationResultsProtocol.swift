
import Foundation

public struct Location {
    public let file: StaticString
    public let function: StaticString
    public let line: Int
}

public struct Diagnostic {
    public let message: String
    public let location: Location
}

public struct Diagnostics {
    public internal(set) var successes: [Diagnostic]
    public internal(set) var warnings: [Diagnostic]
    public internal(set) var errors: [Diagnostic]

    static func + (lhs: Diagnostics, rhs: Diagnostics) -> Diagnostics {
        return Diagnostics(successes: lhs.successes + rhs.successes, warnings: lhs.warnings + rhs.warnings, errors: lhs.errors + rhs.errors)
    }
}

public protocol ValidationResultsProtocol {
    associatedtype Value

    var value: Value { get }
    var local: Diagnostics { get }
    var all: Diagnostics { get }

    subscript<T>(_ keyPath: KeyPath<Value, T>) -> ValidationResults<T> { get }
}
