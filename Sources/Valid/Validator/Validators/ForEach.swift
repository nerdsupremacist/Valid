
import Foundation

public struct ForEach<Input: Collection>: PartialValidator where Input.Index: Hashable {
    private let name: String?
    private let validator: InternalValidator<Input.Element>
    private let location: Location

    public init(file: StaticString = #file,
                function: StaticString = #function,
                line: Int = #line,
                name: String,
                @ValidationRulesBuilder _ rules: () -> BaseValidationRules<Input.Element>) {

        self.validator = rules().validator
        self.name = name
        self.location = Location(file: file, function: function, line: line)
    }

    public init(file: StaticString = #file,
                function: StaticString = #function,
                line: Int = #line,
                @ValidationRulesBuilder _ rules: () -> BaseValidationRules<Input.Element>) {

        self.validator = rules().validator
        self.name = nil
        self.location = Location(file: file, function: function, line: line)
    }

    public var rules: PartialValidationRules<Input> {
        return PartialValidationRules(validator: ForEachValidator(name: name, validator: validator, type: Self.self, location: location))
    }
}

private class ForEachValidator<Input: Collection>: InternalValidator<Input> where Input.Index: Hashable {
    private let name: String?
    private let validator: InternalValidator<Input.Element>
    private let type: Any.Type
    private let location: Location

    init(name: String?, validator: InternalValidator<Input.Element>, type: Any.Type, location: Location) {
        self.name = name
        self.validator = validator
        self.type = type
        self.location = location
    }

    override func validate(input: Input, on context: ValidationContext<Input>) async -> ValidationResult {
        if context.lazy {
            for index in input.indices {
                let result = await context.validate(\.[index], name: nil, using: validator, as: type, location: location)
                switch result {
                case .allow, .deny:
                    return result
                case .skip, .warning:
                    continue
                }
            }

            return .skip
        }

        let results = await input.indices.concurrentMap { await context.validate(\.[$0], name: nil, using: self.validator, as: self.type, location: self.location) }
        for result in results {
            switch result {
            case .allow, .deny:
                return result
            case .skip, .warning:
                continue
            }
        }

        return .skip
    }
}
