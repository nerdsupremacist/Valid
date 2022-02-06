
import Foundation

public struct SomeRule<Wrapped, Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Input = Wrapped?
    public typealias Result = Kind.Result

    public init() { }

    public func evaluate(on input: Wrapped?) async -> ConditionalValidationResult {
        guard input == nil else { return .skip }
        return .met
    }
}

public typealias AllowIfSome<Wrapped> = SomeRule<Wrapped, AllowOnConditionKind>
public typealias DenyIfSome<Wrapped> = SomeRule<Wrapped, DenyOnConditionKind>
public typealias WarnIfSome<Wrapped> = SomeRule<Wrapped, WarnOnConditionKind>
