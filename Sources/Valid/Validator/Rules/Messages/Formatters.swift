
import Foundation

class BlockCustomValidationMessageFormatter<Input>: CustomValidationMessageFormatter {
    private let message: (Input) -> String

    init(message: @escaping (Input) -> String) {
        self.message = message
    }

    func message(from input: Input) -> String {
        return message(input)
    }
}

class HardCodedCustomValidationMessageFormatter<Input>: CustomValidationMessageFormatter {
    private let message: () -> String

    init(message: @autoclosure @escaping () -> String) {
        self.message = message
    }

    func message(from input: Input) -> String {
        return message()
    }
}

class BlockCustomValidationRuleMessageFormatter<Rule: ValidationRule>: CustomValidationRuleMessageFormatter {
    private let message: (Rule.Input, Rule) -> String

    init(message: @escaping (Rule.Input, Rule) -> String) {
        self.message = message
    }

    func message(from input: Rule.Input, on rule: Rule) -> String {
        return message(input, rule)
    }
}
