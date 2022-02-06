
import Foundation

public struct DenyIfContainsTooFewCharactersFromSet: MaybeDenyValidationRule {
    private let characters: CharacterSet
    private let minimum: Int

    public init(_ characters: CharacterSet, minimum: Int) {
        self.characters = characters
        self.minimum = minimum
    }

    public func evaluate(on input: String) async -> MaybeDeny {
        let charactersInSet = input.filter { $0.unicodeScalars.allSatisfy { characters.contains($0) } }
        if charactersInSet.count < minimum {
            return .deny
        }
        return .skip
    }
}
