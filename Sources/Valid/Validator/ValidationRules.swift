
import Foundation

public class BaseValidationRules<Input> {
    let validator: InternalValidator<Input>

    init(validator: InternalValidator<Input>) {
        self.validator = validator
    }
}

public class PartialValidationRules<Input>: BaseValidationRules<Input> {
}

public class ValidationRules<Input>: BaseValidationRules<Input> {
}
