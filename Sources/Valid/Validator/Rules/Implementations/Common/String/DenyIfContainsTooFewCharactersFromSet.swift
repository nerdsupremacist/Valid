
import Foundation

public struct DenyIfContainsTooFewCharactersFromSet: MaybeDenyValidationRule {
    private let characters: CharacterSet
    private let minimum: Int
    private let message: String?

    public init(_ characters: CharacterSet, minimum: Int, message: String? = nil) {
        self.characters = characters
        self.minimum = minimum
        self.message = message
    }

    public func evaluate(on input: String) async -> MaybeDeny {
        let charactersInSet = input.filter { $0.unicodeScalars.allSatisfy { characters.contains($0) } }
        if charactersInSet.count < minimum {
            return .deny(message: message)
        }
        return .skip
    }
}
