
import Foundation

public struct WarnIf<Input>: WarningEmmitter {
    private let message: String
    private let condition: (Input) async -> Bool

    public init(_ message: String, condition: @escaping (Input) async -> Bool) {
        self.message = message
        self.condition = condition
    }

    public func evaluate(on input: Input) async -> MaybeWarn {
        if await condition(input) {
            return .warning(message: message)
        }

        return .skip
    }
}
