
import Foundation

public struct DenyIfTooSmall<Input: Comparable>: MaybeDenyValidationRule {
    public let minimum: Input

    public init(minimum: Input) {
        self.minimum = minimum
    }

    public func evaluate(on input: Input) async -> MaybeDeny {
        if input < minimum {
            return .deny
        }

        return .skip
    }
}
