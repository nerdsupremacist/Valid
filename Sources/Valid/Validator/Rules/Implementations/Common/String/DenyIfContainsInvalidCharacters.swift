
import Foundation

public struct DenyIfContainsInvalidCharacters: MaybeDenyValidationRule {
    public typealias Input = String

    private let allowedCharacters: CharacterSet
    private let formatter: CharactersNotAllowedInStringMessageFormatter?

    fileprivate init(allowedCharacters: CharacterSet, formatter: CharactersNotAllowedInStringMessageFormatter?) {
        self.allowedCharacters = allowedCharacters
        self.formatter = formatter
    }

    fileprivate init(allowedCharacters: CharacterSet, message: @escaping @autoclosure () -> String) {
        self.init(allowedCharacters: allowedCharacters, formatter: HardcodedMessageCharactersNotAllowedInStringMessageFormatter(message: message))
    }

    public init(allowedCharacters: CharacterSet) {
        self.init(allowedCharacters: allowedCharacters, formatter: nil)
    }

    public func evaluate(on input: String) async -> MaybeDeny {
        let invalidCharacters = input.filter { $0.unicodeScalars.contains { !allowedCharacters.contains($0) } } as [Character]
        guard !invalidCharacters.isEmpty else { return .skip }
        let message = formatter?.messageCharactersAreNotAllowed(characters: invalidCharacters, in: input)
        return .deny(message: message)
    }
}

extension DenyIfContainsInvalidCharacters {

    public func withMessage(formatter: CharactersNotAllowedInStringMessageFormatter) -> DenyIfContainsInvalidCharacters {
        return DenyIfContainsInvalidCharacters(allowedCharacters: allowedCharacters, formatter: formatter)
    }

    public func withMessage(formatter closure: @escaping ([Character], String) -> String) -> DenyIfContainsInvalidCharacters {
        return withMessage(formatter: BasicCharactersNotAllowedInStringMessageFormatter(closure: closure))
    }

    public func withMessage(formatter closure: @escaping ([Character]) -> String) -> DenyIfContainsInvalidCharacters {
        return withMessage { characters, _ in closure(characters) }
    }

}

public protocol CharactersNotAllowedInStringMessageFormatter {
    func messageCharactersAreNotAllowed(characters: [Character], in string: String) -> String
}

private struct BasicCharactersNotAllowedInStringMessageFormatter: CharactersNotAllowedInStringMessageFormatter {
    let closure: ([Character], String) -> String

    func messageCharactersAreNotAllowed(characters: [Character], in string: String) -> String {
        return closure(characters, string)
    }
}

private struct HardcodedMessageCharactersNotAllowedInStringMessageFormatter: CharactersNotAllowedInStringMessageFormatter {
    let message: () -> String

    func messageCharactersAreNotAllowed(characters: [Character], in string: String) -> String {
        return message()
    }
}
