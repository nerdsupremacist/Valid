
import Foundation

extension ValidationRule where Result: ValidationResultWhichAllowsOptionalMessage {
    @_disfavoredOverload
    public func message<Formatter: CustomValidationMessageFormatter>(_ formatter: Formatter) -> ValidationRuleWithMessage<Self> where Formatter.Input == Input {
        return ValidationRuleWithMessage(rule: self, formatter: AnyCustomMessageFormatter(formatter: formatter))
    }

    @_disfavoredOverload
    public func message<Formatter: CustomValidationRuleMessageFormatter>(_ formatter: Formatter) -> ValidationRuleWithMessage<Self> where Formatter.Rule == Self {
        return ValidationRuleWithMessage(rule: self, formatter: AnyCustomMessageFormatter(formatter: formatter))
    }

    @_disfavoredOverload
    public func message(_ message: @autoclosure @escaping () -> String) -> ValidationRuleWithMessage<Self> {
        return self.message(HardCodedCustomValidationMessageFormatter(message: message()))
    }

    @_disfavoredOverload
    public func message(_ message: @escaping (Input) -> String) -> ValidationRuleWithMessage<Self> {
        return self.message(BlockCustomValidationMessageFormatter(message: message))
    }

    @_disfavoredOverload
    public func message(_ message: @escaping (Input, Self) -> String) -> ValidationRuleWithMessage<Self> {
        return self.message(BlockCustomValidationRuleMessageFormatter(message: message))
    }
}
