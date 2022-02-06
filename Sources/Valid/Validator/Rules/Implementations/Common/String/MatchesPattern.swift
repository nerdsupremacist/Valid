
import Foundation

public struct MatchesPatternRule<Kind: ConditionalValidationResultKind>: ConditionalValidationRule {
    public typealias Result = Kind.Result

    private let pattern: String
    private let options: NSRegularExpression.Options

    public init(pattern: String, options: NSRegularExpression.Options = []) {
        self.pattern = pattern
        self.options = options
    }

    public func evaluate(on input: String) async -> ConditionalValidationResult {
        do {
            let regularExpression = try NSRegularExpression(pattern: pattern, options: options)
            let range = input.startIndex..<input.endIndex
            let nsRange = NSRange(range, in: input)
            let numberOfMatches = regularExpression.numberOfMatches(in: input, options: .anchored, range: nsRange)
            return numberOfMatches > 0 ? .met : .skip
        } catch {
            return .skip
        }
    }
}

public typealias AllowIfMatchesPattern = MatchesPatternRule<AllowOnConditionKind>
public typealias DenyIfMatchesPattern = MatchesPatternRule<DenyOnConditionKind>
public typealias WarnIfMatchesPattern = MatchesPatternRule<WarnOnConditionKind>
