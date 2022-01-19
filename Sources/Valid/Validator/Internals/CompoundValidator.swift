
import Foundation

final class CompoundValidator<Input>: InternalValidator<Input> {
    let validators: [InternalValidator<Input>]

    init(validators: [InternalValidator<Input>]) {
        self.validators = validators
    }

    override func followed(by validator: InternalValidator<Input>) -> InternalValidator<Input> {
        if let validator = validator as? CompoundValidator {
            return CompoundValidator(validators: validators + validator.validators)
        }
        return CompoundValidator(validators: validators + [validator])
    }

    override func validate(input: Input, on context: ValidationContext<Input>) async -> ValidationResult {
        if context.lazy {
            for validator in validators {
                let result = await context.validate(using: validator)
                switch result {
                case .allow, .deny:
                    return result
                case .skip:
                    continue
                }
            }
        }

        var currentResult: ValidationResult?
        for validator in validators {
            let result = await context.validate(using: validator)
            switch result {
            case .allow, .deny:
                if currentResult == nil {
                    currentResult = result
                }
            case .skip:
                continue
            }
        }
        return currentResult ?? .skip
    }
}
