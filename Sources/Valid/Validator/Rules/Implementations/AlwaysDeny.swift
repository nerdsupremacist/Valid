
import Foundation

public struct AlwaysDeny<Input>: FinalValidationRule {
    private let message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public func evaluate(on input: Input) -> FinalValidation {
        return .deny(message: message)
    }
}
