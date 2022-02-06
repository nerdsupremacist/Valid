
import Foundation

// MARK: - StartsWithSubstring

public struct __StartsWithSubstringRule<Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Input = String
    public typealias Result = Kind.Result

    public let substring: String

    public init(substring: String) {
        self.substring = substring
    }

    public func evaluate(on input: Input) async -> ConditionalValidationResult {
        guard input.hasPrefix(substring) else { return .skip }
        return .met
    }
}

public typealias AllowIfStartsWithSubstring = __StartsWithSubstringRule<AllowOnConditionKind>
public typealias DenyIfStartsWithSubstring = __StartsWithSubstringRule<DenyOnConditionKind>
public typealias WarnIfStartsWithSubstring = __StartsWithSubstringRule<WarnOnConditionKind>


// MARK: - EndsWithSubstring

public struct __EndsWithSubstringRule<Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Input = String
    public typealias Result = Kind.Result

    public let substring: String

    public init(_ substring: String) {
        self.substring = substring
    }

    public func evaluate(on input: Input) async -> ConditionalValidationResult {
        guard input.hasSuffix(substring) else { return .skip }
        return .met
    }
}

public typealias AllowIfEndsWithSubstring = __EndsWithSubstringRule<AllowOnConditionKind>
public typealias DenyIfEndsWithSubstring = __EndsWithSubstringRule<DenyOnConditionKind>
public typealias WarnIfEndsWithSubstring = __EndsWithSubstringRule<WarnOnConditionKind>


// MARK: - Equals

public struct __EqualsRule<Input: Equatable, Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Result = Kind.Result

    public let expected: Input

    public init(_ expected: Input) {
        self.expected = expected
    }

    public func evaluate(on input: Input) async -> ConditionalValidationResult {
        guard input == expected else { return .skip }
        return .met
    }
}

public typealias AllowIfEquals<Input: Equatable> = __EqualsRule<Input, AllowOnConditionKind>
public typealias DenyIfEquals<Input: Equatable> = __EqualsRule<Input, DenyOnConditionKind>
public typealias WarnIfEquals<Input: Equatable> = __EqualsRule<Input, WarnOnConditionKind>

// MARK: - Different

public struct __DifferentRule<Input: Equatable, Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Result = Kind.Result

    public let comparedValue: Input

    public init(from comparedValue: Input) {
        self.comparedValue = comparedValue
    }

    public func evaluate(on input: Input) async -> ConditionalValidationResult {
        guard input != comparedValue else { return .skip }
        return .met
    }
}

public typealias AllowIfDifferent<Input: Equatable> = __DifferentRule<Input, AllowOnConditionKind>
public typealias DenyIfDifferent<Input: Equatable> = __DifferentRule<Input, DenyOnConditionKind>
public typealias WarnIfDifferent<Input: Equatable> = __DifferentRule<Input, WarnOnConditionKind>

// MARK: - Contains

public struct __ContainsRule<Input: Sequence, Kind: ConditionalValidationResultKind>: ConditionalValidationRule where Input.Element: Hashable {
    public typealias Result = Kind.Result

    public let needle: Input.Element

    public init(_ needle: Input.Element) {
        self.needle = needle
    }

    public func evaluate(on input: Input) async -> ConditionalValidationResult {
        guard input.contains(needle) else { return .skip }
        return .met
    }
}

public typealias AllowIfContains<Input: Sequence> = __ContainsRule<Input, AllowOnConditionKind> where Input.Element: Hashable
public typealias DenyIfContains<Input: Sequence> = __ContainsRule<Input, DenyOnConditionKind> where Input.Element: Hashable
public typealias WarnIfContains<Input: Sequence> = __ContainsRule<Input, WarnOnConditionKind> where Input.Element: Hashable

// MARK: - SmallerThan

public struct __SmallerThanRule<Input: Collection, Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Result = Kind.Result

    public let size: Int

    public init(_ size: Int) {
        self.size = size
    }

    public func evaluate(on input: Input) async -> ConditionalValidationResult {
        guard input.count < size else { return .skip }
        return .met
    }
}

public typealias AllowIfSmallerThan<Input: Collection> = __SmallerThanRule<Input, AllowOnConditionKind>
public typealias DenyIfSmallerThan<Input: Collection> = __SmallerThanRule<Input, DenyOnConditionKind>
public typealias WarnIfSmallerThan<Input: Collection> = __SmallerThanRule<Input, WarnOnConditionKind>

// MARK: - LargerThan

public struct __LargerThanRule<Input: Collection, Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Result = Kind.Result

    public let size: Int

    public init(_ size: Int) {
        self.size = size
    }

    public func evaluate(on input: Input) async -> ConditionalValidationResult {
        guard input.count > size else { return .skip }
        return .met
    }
}

public typealias AllowIfLargerThan<Input: Collection> = __LargerThanRule<Input, AllowOnConditionKind>
public typealias DenyIfLargerThan<Input: Collection> = __LargerThanRule<Input, DenyOnConditionKind>
public typealias WarnIfLargerThan<Input: Collection> = __LargerThanRule<Input, WarnOnConditionKind>

// MARK: - Empty

public struct __EmptyRule<Input: Collection, Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Result = Kind.Result


    public init() {
    }

    public func evaluate(on input: Input) async -> ConditionalValidationResult {
        guard input.isEmpty else { return .skip }
        return .met
    }
}

public typealias AllowIfEmpty<Input: Collection> = __EmptyRule<Input, AllowOnConditionKind>
public typealias DenyIfEmpty<Input: Collection> = __EmptyRule<Input, DenyOnConditionKind>
public typealias WarnIfEmpty<Input: Collection> = __EmptyRule<Input, WarnOnConditionKind>

// MARK: - NotEmpty

public struct __NotEmptyRule<Input: Collection, Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Result = Kind.Result


    public init() {
    }

    public func evaluate(on input: Input) async -> ConditionalValidationResult {
        guard !input.isEmpty else { return .skip }
        return .met
    }
}

public typealias AllowIfNotEmpty<Input: Collection> = __NotEmptyRule<Input, AllowOnConditionKind>
public typealias DenyIfNotEmpty<Input: Collection> = __NotEmptyRule<Input, DenyOnConditionKind>
public typealias WarnIfNotEmpty<Input: Collection> = __NotEmptyRule<Input, WarnOnConditionKind>

// MARK: - PartOfSet

public struct __PartOfSetRule<Input: Hashable, Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Result = Kind.Result

    public let set: Set<Input>

    public init(_ set: Set<Input>) {
        self.set = set
    }

    public func evaluate(on input: Input) async -> ConditionalValidationResult {
        guard set.contains(input) else { return .skip }
        return .met
    }
}

public typealias AllowIfPartOfSet<Input: Hashable> = __PartOfSetRule<Input, AllowOnConditionKind>
public typealias DenyIfPartOfSet<Input: Hashable> = __PartOfSetRule<Input, DenyOnConditionKind>
public typealias WarnIfPartOfSet<Input: Hashable> = __PartOfSetRule<Input, WarnOnConditionKind>
