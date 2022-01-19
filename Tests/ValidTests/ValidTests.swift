import XCTest
import Valid

struct PasswordValidator: Validator {
    var rules: ValidationRules<String> {
        DenyIfContainsInvalidCharacters(allowedCharacters: .letters.union(.decimalDigits).union(.punctuationCharacters))
            .withMessage { characters in
                let list = characters.map { "\"\($0)\"" }.joined(separator: ", ")
                return "Characters \(list) are not allowed"
            }

        Property(\String.count) {
            DenyIf(message: "Length must not be even") { $0 % 2 == 0 }

            DenyIfTooSmall(minimum: 8)
        }

        AlwaysAllow<String>()
    }
}


final class ValidTests: XCTestCase {
    func testExample() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "12😂345", lazy: false)
        print(results.all.errors)
    }
}
