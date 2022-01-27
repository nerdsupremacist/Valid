
import Foundation

public enum MaybeWarn {
    case warning(message: String)
    case skip
}

public protocol WarningEmmitter: ValidationRule where Result == MaybeWarn {
    associatedtype Input

    func evaluate(on input: Input) async -> MaybeWarn
}

extension WarningEmmitter {

    public func evaluate(on input: Input) async -> ValidationResult {
        switch await evaluate(on: input) {
        case .warning(let message):
            return .warning(message: message)
        case .skip:
            return .skip
        }
    }

}
