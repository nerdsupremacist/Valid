
import Foundation

public struct AlwaysAllow<Input>: FinalValidationRule {
    private let message: String?

    public init(_ message: String? = nil) {
        self.message = message
    }

    public func evaluate(on input: Input) -> FinalValidation {
        return .allow(message: message)
    }
}
