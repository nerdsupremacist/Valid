
import Foundation

final class ValidationRuleValidator<Input>: InternalValidator<Input> {
    private class Storage {
        var type: Any.Type {
            return Int.self
        }

        func evaluate(on input: Input) async -> ValidationResult {
            return .skip
        }
    }

    private final class RuleStorage<R: ValidationRule>: Storage where R.Input == Input {
        private let rule: R

        init(rule: R) {
            self.rule = rule
        }

        override var type: Any.Type {
            return R.self
        }

        override func evaluate(on input: Input) async -> ValidationResult {
            return await rule.evaluate(on: input)
        }
    }

    private let storage: Storage
    private let location: Location

    init<R : ValidationRule>(rule: R, file: StaticString, function: StaticString, line: Int) where R.Input == Input {
        self.storage = RuleStorage(rule: rule)
        self.location = Location(file: file, function: function, line: line)
    }

    override func validate(input: Input, on context: ValidationContext<Input>) async -> ValidationResult {
        let result = await storage.evaluate(on: input)
        await context.check(Check(type: storage.type, kind: .validation(result), location: location))
        switch result {
        case .allow(.some(let message)):
            await context.success(Diagnostic(message: message, location: location))
        case .deny(.some(let message)):
            await context.error(Diagnostic(message: message, location: location))
        case .warning(let message):
            await context.warning(Diagnostic(message: message, location: location))
        case .allow, .deny, .skip:
            break
        }
        return result
    }
}
