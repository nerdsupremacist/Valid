
import Foundation

@resultBuilder
public struct ValidationRulesBuilder {
    public static func buildExpression<T : MaybeAllowValidationRule>(_ expression: T,
                                                                     file: StaticString = #file,
                                                                     function: StaticString = #function,
                                                                     line: Int = #line) -> PartialValidationRules<T.Input> {

        return PartialValidationRules(validator: ValidationRuleValidator(rule: expression, file: file, function: function, line: line))
    }

    public static func buildExpression<T : MaybeDenyValidationRule>(_ expression: T,
                                                                    file: StaticString = #file,
                                                                    function: StaticString = #function,
                                                                    line: Int = #line) -> PartialValidationRules<T.Input> {

        return PartialValidationRules(validator: ValidationRuleValidator(rule: expression, file: file, function: function, line: line))
    }

    public static func buildExpression<T : FinalValidationRule>(_ expression: T,
                                                                file: StaticString = #file,
                                                                function: StaticString = #function,
                                                                line: Int = #line) -> ValidationRules<T.Input> {

        return ValidationRules(validator: ValidationRuleValidator(rule: expression, file: file, function: function, line: line))
    }

    public static func buildExpression<T : PartialValidator>(_ expression: T) -> PartialValidationRules<T.Input> {
        return expression.rules
    }

    public static func buildExpression<T : Validator>(_ expression: T) -> ValidationRules<T.Input> {
        return expression.rules
    }

    public static func buildExpression<Input>(_ expression: PartialValidationRules<Input>) -> PartialValidationRules<Input> {
        return expression
    }

    public static func buildExpression<Input>(_ expression: ValidationRules<Input>) -> ValidationRules<Input> {
        return expression
    }
}

extension ValidationRulesBuilder {
    public static func buildEither<Input>(first component: PartialValidationRules<Input>) -> PartialValidationRules<Input> {
        return component
    }

    public static func buildEither<Input>(second component: PartialValidationRules<Input>) -> PartialValidationRules<Input> {
        return component
    }

    public static func buildEither<Input>(first component: ValidationRules<Input>) -> ValidationRules<Input> {
        return component
    }

    public static func buildEither<Input>(second component: ValidationRules<Input>) -> ValidationRules<Input> {
        return component
    }
}

extension ValidationRulesBuilder {
    public static func buildOptional<Input>(_ component: PartialValidationRules<Input>?) -> PartialValidationRules<Input> {
        return component ?? PartialValidationRules(validator: InternalValidator())
    }

    public static func buildOptional<Input>(_ component: ValidationRules<Input>?) -> PartialValidationRules<Input> {
        return PartialValidationRules(validator: component?.validator ?? InternalValidator())
    }
}

extension ValidationRulesBuilder {
    public static func buildArray<Input>(_ components: [PartialValidationRules<Input>]) -> PartialValidationRules<Input> {
        return PartialValidationRules(validator: CompoundValidator(validators: components.map(\.validator)))
    }
}

extension ValidationRulesBuilder {
    public static func buildBlock<Input>() -> PartialValidationRules<Input> {
        return PartialValidationRules(validator: InternalValidator())
    }

    public static func buildBlock<Input>(_ components: PartialValidationRules<Input>...) -> PartialValidationRules<Input> {
        return PartialValidationRules(validator: CompoundValidator(validators: components.map(\.validator)))
    }

    public static func buildBlock<Input>(_ component: ValidationRules<Input>) -> ValidationRules<Input> {
        return component
    }

    public static func buildBlock<Input>(_ c0: PartialValidationRules<Input>, _ c1: ValidationRules<Input>) -> ValidationRules<Input> {
        return ValidationRules(validator: c0.validator.followed(by: c1.validator))
    }

    public static func buildBlock<Input>(_ c0: PartialValidationRules<Input>, _ c1: PartialValidationRules<Input>, _ c2: ValidationRules<Input>) -> ValidationRules<Input> {
        return ValidationRules(validator: c0.validator.followed(by: c1.validator).followed(by: c2.validator))
    }

    public static func buildBlock<Input>(_ c0: PartialValidationRules<Input>, _ c1: PartialValidationRules<Input>, _ c2: PartialValidationRules<Input>, _ c3: ValidationRules<Input>) -> ValidationRules<Input> {
        return ValidationRules(validator: c0.validator.followed(by: c1.validator).followed(by: c2.validator).followed(by: c3.validator))
    }
}
