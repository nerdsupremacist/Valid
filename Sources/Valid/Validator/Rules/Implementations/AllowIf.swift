
import Foundation

public struct AllowIf<Input>: MaybeAllowValidationRule {
    private let message: String?
    private let condition: (Input) async -> Bool

    public init(_ message: String? = nil, condition: @escaping (Input) async -> Bool) {
        self.message = message
        self.condition = condition
    }

    public func evaluate(on input: Input) async -> MaybeAllow {
        if await condition(input) {
            return .allow(message: message)
        }

        return .skip
    }
}
