
import Foundation

public enum MaybeAllow {
    case allow(message: String? = nil)
    case skip
}

extension MaybeAllow {
    public static let allow: MaybeAllow = .allow()
}

public protocol MaybeAllowValidationRule: ValidationRule where Result == MaybeAllow {
    associatedtype Input

    func evaluate(on input: Input) async -> MaybeAllow
}

extension MaybeAllowValidationRule {

    public func evaluate(on input: Input) async -> ValidationResult {
        switch await evaluate(on: input) {
        case .allow(let message):
            return .allow(message: message)
        case .skip:
            return .skip
        }
    }

}
