
import Foundation

public protocol CustomValidationRuleMessageFormatter {
    associatedtype Rule: ValidationRule

    func message(from input: Rule.Input, on rule: Rule) -> String
}
