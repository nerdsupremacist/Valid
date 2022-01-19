
import Foundation

public struct AllowIfMatchesPattern: MaybeAllowValidationRule {
    private let pattern: String
    private let options: NSRegularExpression.Options
    private let message: String?

    public init(pattern: String, options: NSRegularExpression.Options = [], message: String? = nil) {
        self.pattern = pattern
        self.options = options
        self.message = message
    }

    public func evaluate(on input: String) async -> MaybeAllow {
        do {
            let regularExpression = try NSRegularExpression(pattern: pattern, options: options)
            let range = input.startIndex..<input.endIndex
            let nsRange = NSRange(range, in: input)
            let numberOfMatches = regularExpression.numberOfMatches(in: input, options: .anchored, range: nsRange)
            return numberOfMatches > 0 ? .allow(message: message) : .skip
        } catch {
            return .skip
        }
    }
}
