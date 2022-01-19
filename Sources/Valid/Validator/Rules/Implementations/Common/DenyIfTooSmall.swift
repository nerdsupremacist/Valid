
import Foundation

public struct DenyIfTooSmall<Input: Comparable>: MaybeDenyValidationRule {
    public typealias MessageBuilder = (Input, Input) -> String

    private let minimum: Input
    private let message: MessageBuilder
    
    public init(minimum: Input) {
        self.minimum = minimum
        self.message = DenyIfTooSmall<Input>.standardMessage(input:minimum:)
    }

    public init(minimum: Input, message: String) {
        self.minimum = minimum
        self.message = { _, _ in message }
    }

    public init(minimum: Input, message: @escaping MessageBuilder) {
        self.minimum = minimum
        self.message = message
    }

    public func evaluate(on input: Input) async -> MaybeDeny {
        if input < minimum {
            let message = self.message(input, minimum)
            return .deny(message: message)
        }

        return .skip
    }
}

extension DenyIfTooSmall {

    private static func standardMessage(input: Input, minimum: Input) -> String {
        return "Expected \(input) to be at least \(minimum)"
    }

}
