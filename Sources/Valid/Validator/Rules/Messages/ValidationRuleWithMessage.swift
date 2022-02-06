
import Foundation

public struct ValidationRuleWithMessage<Rule: ValidationRule>: ValidationRule {
    public typealias Result = Rule.Result
    public typealias Input = Rule.Input

    private let rule: Rule
    private let formatter: AnyCustomMessageFormatter<Rule>

    init(rule: Rule, formatter: AnyCustomMessageFormatter<Rule>) {
        self.rule = rule
        self.formatter = formatter
    }

    public func evaluate(on input: Rule.Input) async -> ValidationResult {
        switch await rule.evaluate(on: input) {
        case .deny:
            return .deny(message: formatter.message(from: input, on: rule))
        case .allow:
            return .allow(message: formatter.message(from: input, on: rule))
        case .warning:
            return .warning(message: formatter.message(from: input, on: rule))
        case .skip:
            return .skip
        }
    }
}

extension ValidationRuleWithMessage {
    public func message<Formatter: CustomValidationMessageFormatter>(_ formatter: Formatter) -> ValidationRuleWithMessage<Rule> where Formatter.Input == Rule.Input {
        return ValidationRuleWithMessage(rule: rule, formatter: AnyCustomMessageFormatter(formatter: formatter))
    }

    public func message<Formatter: CustomValidationRuleMessageFormatter>(_ formatter: Formatter) -> ValidationRuleWithMessage<Rule> where Formatter.Rule == Rule {
        return ValidationRuleWithMessage(rule: rule, formatter: AnyCustomMessageFormatter(formatter: formatter))
    }
}

extension ValidationRuleWithMessage {
    public func message(_ message: @autoclosure @escaping () -> String) -> Self {
        return self.message(HardCodedCustomValidationMessageFormatter(message: message()))
    }

    public func message(_ message: @escaping (Input) -> String) -> Self {
        return self.message(BlockCustomValidationMessageFormatter(message: message))
    }

    public func message(_ message: @escaping (Input, Rule) -> String) -> Self {
        return self.message(BlockCustomValidationRuleMessageFormatter(message: message))
    }
}

extension ValidationRuleWithMessage: MaybeAllowValidationRule where Rule: MaybeAllowValidationRule {

    public func evaluate(on input: Input) async -> MaybeAllow {
        switch await rule.evaluate(on: input) as MaybeAllow {
        case .allow:
            return .allow(message: formatter.message(from: input, on: rule))
        case .skip:
            return .skip
        }
    }

}

extension ValidationRuleWithMessage: MaybeDenyValidationRule where Rule: MaybeDenyValidationRule {

    public func evaluate(on input: Input) async -> MaybeDeny {
        switch await rule.evaluate(on: input) as MaybeDeny {
        case .deny:
            return .deny(message: formatter.message(from: input, on: rule))
        case .skip:
            return .skip
        }
    }

}

extension ValidationRuleWithMessage: WarningEmmitter where Rule: WarningEmmitter {

    public func evaluate(on input: Input) async -> MaybeWarn {
        switch await rule.evaluate(on: input) as MaybeWarn {
        case .warning:
            return .warning(message: formatter.message(from: input, on: rule))
        case .skip:
            return .skip
        }
    }

}

extension ValidationRuleWithMessage: ConditionalValidationRule where Rule: ConditionalValidationRule {
    public typealias Kind = Rule.Kind

    public func evaluate(on input: Rule.Input) async -> ConditionalValidationResult {
        switch await rule.evaluate(on: input) as ConditionalValidationResult {
        case .met:
            return .met(message: formatter.message(from: input, on: rule))
        case .skip:
            return .skip
        }
    }
}
