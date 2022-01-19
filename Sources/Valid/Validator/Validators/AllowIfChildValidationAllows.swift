
import Foundation

public struct AllowIfChildValidationAllows<Input>: PartialValidator {
    private let name: String?
    private let validator: InternalValidator<Input>
    private let location: Location

    public init(file: StaticString = #file,
                function: StaticString = #function,
                line: Int = #line,
                name: String,
                @ValidationRulesBuilder _ rules: () -> BaseValidationRules<Input>) {

        self.validator = rules().validator
        self.name = name
        self.location = Location(file: file, function: function, line: line)
    }

    public init(file: StaticString = #file,
                function: StaticString = #function,
                line: Int = #line,
                @ValidationRulesBuilder _ rules: () -> BaseValidationRules<Input>) {

        self.validator = rules().validator
        self.name = nil
        self.location = Location(file: file, function: function, line: line)
    }

    public var rules: PartialValidationRules<Input> {
        return PartialValidationRules(validator: InternalAllowIfChildValidationAllowsValidator(name: name, validator: validator, location: location))
    }
}

private final class InternalAllowIfChildValidationAllowsValidator<Input>: InternalValidator<Input> {
    private let name: String?
    private let validator: InternalValidator<Input>
    private let location: Location

    init(name: String?, validator: InternalValidator<Input>, location: Location) {
        self.name = name
        self.validator = validator
        self.location = location
    }

    override func validate(input: Input, on context: ValidationContext<Input>) async -> ValidationResult {
        let result = await context.validateSubGroup(name: name, using: validator, as: AllowIfChildValidationAllows<Input>.self, location: location)
        switch result {
        case .allow:
            return result
        case .skip, .deny:
            return .skip
        }
    }
}
