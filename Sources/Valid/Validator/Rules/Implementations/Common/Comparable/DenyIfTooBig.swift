
import Foundation

public struct DenyIfTooBig<Input: Comparable>: MaybeDenyValidationRule {
    public let maximum: Input

    public init(maximum: Input) {
        self.maximum = maximum
    }

    public func evaluate(on input: Input) async -> MaybeDeny {
        if input > maximum {
            return .deny
        }

        return .skip
    }
}
