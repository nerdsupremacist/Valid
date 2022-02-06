
import Foundation

public struct NoneRule<Wrapped, Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Input = Wrapped?
    public typealias Result = Kind.Result

    public init() { }

    public func evaluate(on input: Wrapped?) async -> ConditionalValidationResult {
        guard input == nil else { return .skip }
        return .met
    }
}

public typealias AllowIfNone<Wrapped> = NoneRule<Wrapped, AllowOnConditionKind>
public typealias DenyIfNone<Wrapped> = NoneRule<Wrapped, DenyOnConditionKind>
public typealias WarnIfNone<Wrapped> = NoneRule<Wrapped, WarnOnConditionKind>
