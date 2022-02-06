
import Foundation

public struct AllowIfAllCharactersAreValid: MaybeAllowValidationRule {
    public typealias Input = String

    private let allowedCharacters: CharacterSet

    public func evaluate(on input: String) async -> MaybeAllow {
        let areAllValid = input.flatMap(\.unicodeScalars).allSatisfy { allowedCharacters.contains($0) }
        guard areAllValid else { return .skip }
        return .allow
    }
}
