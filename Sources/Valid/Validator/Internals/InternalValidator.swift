
import Foundation

class InternalValidator<Input> {
    func followed(by validator: InternalValidator<Input>) -> InternalValidator<Input> {
        if let validator = validator as? CompoundValidator {
            return CompoundValidator(validators: [self] + validator.validators)
        }

        return CompoundValidator(validators: [self, validator])
    }

    func validate(input: Input, on context: ValidationContext<Input>) async -> ValidationResult {
        return .skip
    }
}
