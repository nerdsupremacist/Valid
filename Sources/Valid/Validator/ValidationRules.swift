
import Foundation

public class BaseValidationRules<Input> {
    let validator: InternalValidator<Input>

    init(validator: InternalValidator<Input>) {
        self.validator = validator
    }
}

public final class PartialValidationRules<Input>: BaseValidationRules<Input> {
}

public final class ValidationRules<Input>: BaseValidationRules<Input> {
}
