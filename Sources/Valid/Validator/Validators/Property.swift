
import Foundation

public struct Property<Input, T, Rules: BaseValidationRules<T>> {
    private let name: String?
    private let keyPath: KeyPath<Input, T>
    private let location: Location
    private let validator: InternalValidator<T>

    private init(name: String?, keyPath: KeyPath<Input, T>, location: Location, validator: InternalValidator<T>) {
        self.name = name
        self.keyPath = keyPath
        self.location = location
        self.validator = validator
    }
}

extension Property: Validator where Rules == ValidationRules<T> {
    public init(_ keyPath: KeyPath<Input, T>,
                name: String? = nil,
                file: StaticString = #file,
                function: StaticString = #function,
                line: Int = #line,
                @ValidationRulesBuilder rules: () -> ValidationRules<T>) {

        self.init(name: name, keyPath: keyPath, location: Location(file: file, function: function, line: line), validator: rules().validator)
    }

    public var rules: ValidationRules<Input> {
        PartialValidationRules<Input>(validator: PropertyValidator(name: name, keyPath: keyPath, location: location, type: Self.self, validator: validator))

        AlwaysDeny<Input>()
    }
}

extension Property: PartialValidator where Rules == PartialValidationRules<T> {
    public init(_ keyPath: KeyPath<Input, T>,
                name: String? = nil,
                file: StaticString = #file,
                function: StaticString = #function,
                line: Int = #line,
                @ValidationRulesBuilder rules: () -> PartialValidationRules<T>) {

        self.init(name: name, keyPath: keyPath, location: Location(file: file, function: function, line: line), validator: rules().validator)
    }

    public var rules: PartialValidationRules<Input> {
        return PartialValidationRules<Input>(validator: PropertyValidator(name: name, keyPath: keyPath, location: location, type: Self.self, validator: validator))
    }
}

private final class PropertyValidator<Input, T>: InternalValidator<Input> {
    private let name: String?
    private let keyPath: KeyPath<Input, T>
    private let location: Location
    private let type: Any.Type
    private let validator: InternalValidator<T>

    init(name: String?, keyPath: KeyPath<Input, T>, location: Location, type: Any.Type, validator: InternalValidator<T>) {
        self.name = name
        self.keyPath = keyPath
        self.location = location
        self.type = type
        self.validator = validator
    }

    override func validate(input: Input, on context: ValidationContext<Input>) async -> ValidationResult {
        return await context.validate(keyPath, name: name, using: validator, as: type, location: location)
    }
}
