
import Foundation

public protocol Validator {
    associatedtype Input

    @ValidationRulesBuilder
    var rules: ValidationRules<Input> { get }
}

extension Validator {

    public func validate(input: Input, lazy: Bool = true) async -> Validation<Input> {
        let context = ValidationContext(value: input, lazy: lazy)
        let result = await context.validate(using: rules.validator)
        let verdict: Validation<Input>.Verdict
        switch result {
        case .allow(let message):
            verdict = .allow(message: message)
        case .deny(let message):
            verdict = .deny(message: message)
        case .skip:
            verdict = .deny(message: nil)
        }
        return Validation(verdict: verdict, checks: await context.checks, results: await context.build())
    }

    public func isValid(input: Input) async -> Bool {
        let validation = await validate(input: input)
        switch validation.verdict {
        case .allow:
            return true
        case .deny:
            return false
        }
    }

    public func checks(input: Input, lazy: Bool) async -> [Check] {
        let validation = await validate(input: input, lazy: lazy)
        return validation.checks
    }

}
