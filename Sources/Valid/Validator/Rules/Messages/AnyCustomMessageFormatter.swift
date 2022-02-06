
import Foundation

class AnyCustomMessageFormatter<Rule: ValidationRule>: CustomValidationRuleMessageFormatter {
    private class AnyStorage {
        func message(from input: Rule.Input, on rule: Rule) -> String {
            fatalError()
        }
    }

    private class RuleFormatterStorage<Formatter: CustomValidationRuleMessageFormatter>: AnyStorage where Formatter.Rule == Rule {
        let formatter: Formatter

        init(formatter: Formatter) {
            self.formatter = formatter
            super.init()
        }

        override func message(from input: Rule.Input, on rule: Rule) -> String {
            return formatter.message(from: input, on: rule)
        }
    }

    private class RegularFormatterStorage<Formatter: CustomValidationMessageFormatter>: AnyStorage where Formatter.Input == Rule.Input {
        let formatter: Formatter

        init(formatter: Formatter) {
            self.formatter = formatter
            super.init()
        }

        override func message(from input: Rule.Input, on rule: Rule) -> String {
            return formatter.message(from: input)
        }
    }

    private let storage: AnyStorage

    init<Formatter: CustomValidationRuleMessageFormatter>(formatter: Formatter) where Formatter.Rule == Rule {
        self.storage = RuleFormatterStorage(formatter: formatter)
    }

    init<Formatter: CustomValidationMessageFormatter>(formatter: Formatter) where Formatter.Input == Rule.Input {
        self.storage = RegularFormatterStorage(formatter: formatter)
    }

    func message(from input: Rule.Input, on rule: Rule) -> String {
        return storage.message(from: input, on: rule)
    }
}
