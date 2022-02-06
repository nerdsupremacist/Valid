
import Foundation

public protocol ConditionalValidationResultKind {
    associatedtype Result

    static func conditionMet(with message: String?) -> ValidationResult
}

public enum AllowOnConditionKind: ConditionalValidationResultKind {
    public typealias Result = MaybeAllow

    public static func conditionMet(with message: String?) -> ValidationResult {
        return .allow(message: message)
    }
}

public enum DenyOnConditionKind: ConditionalValidationResultKind {
    public typealias Result = MaybeDeny

    public static func conditionMet(with message: String?) -> ValidationResult {
        return .deny(message: message)
    }
}

public enum WarnOnConditionKind: ConditionalValidationResultKind {
    public typealias Result = MaybeWarn

    public static func conditionMet(with message: String?) -> ValidationResult {
        guard let message = message else { return .skip }
        return .warning(message: message)
    }
}

public enum ConditionalValidationResult {
    case met(message: String? = nil)
    case skip
}

extension ConditionalValidationResult {
    public static let met: ConditionalValidationResult = .met()
}

public protocol ConditionalValidationRule: ValidationRule where Result == Kind.Result {
    associatedtype Input
    associatedtype Kind: ConditionalValidationResultKind

    func evaluate(on input: Input) async -> ConditionalValidationResult
}

extension ConditionalValidationRule {
    public func evaluate(on input: Input) async -> ValidationResult {
        switch await evaluate(on: input) as ConditionalValidationResult {
        case .met(let message):
            return Kind.conditionMet(with: message)
        case .skip:
            return .skip
        }
    }
}
