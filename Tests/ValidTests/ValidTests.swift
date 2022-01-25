import XCTest
import Valid

struct PasswordValidator: Validator {
    var rules: ValidationRules<String> {
        DenyIfContainsInvalidCharacters(allowedCharacters: .letters.union(.decimalDigits).union(.punctuationCharacters))
            .withMessage { characters in
                let list = characters.map { "\"\($0)\"" }.joined(separator: ", ")
                return "Characters \(list) are not allowed"
            }

        DenyIfContainsTooFewCharactersFromSet(.decimalDigits, minimum: 2, message: "Must contain at least 2 numbers")

        DenyIfContainsTooFewCharactersFromSet(.capitalizedLetters, minimum: 1, message: "Must contain at least 1 capitalized letter")

        Property(\String.count) {
            DenyIf("Length must not be even") { $0 % 2 == 0 }

            DenyIfTooSmall(minimum: 8, message: "Must be at least 8 characters long")
        }

        AlwaysAllow<String>()
    }
}


final class ValidTests: XCTestCase {
    func testExample() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "12😂345", lazy: false)
        print(results.all.errors)
        print(results.checks)
    }
}
