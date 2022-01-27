
import Foundation

public enum ValidationResult {
    case allow(message: String? = nil)
    case deny(message: String? = nil)
    case warning(message: String)
    case skip
}

public protocol ValidationRule {
    associatedtype Result
    associatedtype Input

    func evaluate(on input: Input) async -> ValidationResult
}
