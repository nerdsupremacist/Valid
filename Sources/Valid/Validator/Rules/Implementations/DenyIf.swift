
import Foundation

public struct DenyIf<Input>: MaybeDenyValidationRule {
    private let message: String?
    private let condition: (Input) async -> Bool

    public init(_ message: String? = nil, condition: @escaping (Input) async -> Bool) {
        self.message = message
        self.condition = condition
    }

    public func evaluate(on input: Input) async -> MaybeDeny {
        if await condition(input) {
            return .deny(message: message)
        }

        return .skip
    }
}
