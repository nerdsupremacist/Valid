
import Foundation

public enum FinalValidation {
    case allow(message: String? = nil)
    case deny(message: String? = nil)
}

extension FinalValidation {
    public static let allow: FinalValidation = .allow()
    public static let deny: FinalValidation = .deny()
}

public protocol FinalValidationRule: ValidationRule where Result == FinalValidation {
    associatedtype Input
    
    func evaluate(on input: Input) async -> FinalValidation
}

extension FinalValidationRule {

    public func evaluate(on input: Input) async -> ValidationResult {
        switch await evaluate(on: input) {
        case .allow(let message):
            return .allow(message: message)
        case .deny(let message):
            return .deny(message: message)
        }
    }

}
