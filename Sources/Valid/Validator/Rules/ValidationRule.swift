
import Foundation

public enum ValidationResult {
    case allow(message: String? = nil)
    case deny(message: String? = nil)
    case skip
}

public protocol ValidationRule {
    associatedtype Result
    associatedtype Input

    func evaluate(on input: Input) async -> ValidationResult
}

extension ValidationRule {
    var type: Any.Type {
        return Self.self
    }
}
