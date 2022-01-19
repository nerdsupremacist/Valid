
import Foundation

public struct DenyIfTooBig<Input: Comparable>: MaybeDenyValidationRule {
    public typealias MessageBuilder = (Input, Input) -> String

    private let maximum: Input
    private let message: MessageBuilder

    public init(maximum: Input) {
        self.maximum = maximum
        self.message = DenyIfTooBig<Input>.standardMessage(input:minimum:)
    }

    public init(maximum: Input, message: String) {
        self.maximum = maximum
        self.message = { _, _ in message }
    }

    public init(maximum: Input, message: @escaping MessageBuilder) {
        self.maximum = maximum
        self.message = message
    }

    public func evaluate(on input: Input) async -> MaybeDeny {
        if input > maximum {
            let message = self.message(input, maximum)
            return .deny(message: message)
        }

        return .skip
    }
}

extension DenyIfTooBig {

    private static func standardMessage(input: Input, minimum: Input) -> String {
        return "Expected \(input) to be less than \(minimum)"
    }

}
