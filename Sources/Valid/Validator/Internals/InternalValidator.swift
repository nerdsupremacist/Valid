
import Foundation

class InternalValidator<Input> {

    func validate(input: Input, on context: ValidationContext<Input>) async -> ValidationResult {
        return .skip
    }
}
