
import Foundation

public struct AllowIfAllCharactersAreValid: MaybeAllowValidationRule {
    public typealias Input = String

    private let allowedCharacters: CharacterSet
    private let message: String?

    public init(allowedCharacters: CharacterSet, message: String? = nil) {
        self.allowedCharacters = allowedCharacters
        self.message = message
    }

    public func evaluate(on input: String) async -> MaybeAllow {
        let areAllValid = input.flatMap(\.unicodeScalars).allSatisfy { allowedCharacters.contains($0) }
        guard areAllValid else { return .skip }
        return .allow(message: message)
    }
}
