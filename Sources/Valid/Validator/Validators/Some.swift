
import Foundation

public struct Some<Wrapped>: PartialValidator {
    public typealias Input = Wrapped?

    private let validator: InternalValidator<Wrapped>
    private let location: Location

    public init(file: StaticString = #file,
                function: StaticString = #function,
                line: Int = #line,
                @ValidationRulesBuilder _ rules: () -> BaseValidationRules<Wrapped>) {

        self.validator = rules().validator
        self.location = Location(file: file, function: function, line: line)
    }

    public var rules: PartialValidationRules<Input> {
        return PartialValidationRules(validator: SomeValidator(validator: validator, type: Self.self, location: location))
    }
}

private class SomeValidator<Wrapped>: InternalValidator<Wrapped?> {
    private let validator: InternalValidator<Wrapped>
    private let type: Any.Type
    private let location: Location

    init(validator: InternalValidator<Wrapped>, type: Any.Type, location: Location) {
        self.validator = validator
        self.type = type
        self.location = location
    }

    override func validate(input: Wrapped?, on context: ValidationContext<Wrapped?>) async -> ValidationResult {
        return await context.validateForSome(using: validator, as: type, location: location)
    }
}
