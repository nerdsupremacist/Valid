
import Foundation

public enum MaybeDeny {
    case deny(message: String? = nil)
    case skip
}

extension MaybeDeny {
    public static let deny: MaybeDeny = .deny()
}

public protocol MaybeDenyValidationRule: ValidationRule where Result == MaybeDeny {
    associatedtype Input
    
    func evaluate(on input: Input) async -> MaybeDeny
}

extension MaybeDenyValidationRule {

    public func evaluate(on input: Input) async -> ValidationResult {
        switch await evaluate(on: input) {
        case .deny(let message):
            return .deny(message: message)
        case .skip:
            return .skip
        }
    }

}
