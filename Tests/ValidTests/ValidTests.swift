import XCTest
import Valid

extension Set where Element == String {
    static let bannedPasswords: Set<String> = [
        "password",
        "123456"
    ]
}

extension CharacterSet {
    public static let allowedPasswordCharacters: CharacterSet = .letters.union(.decimalDigits).union(.punctuationCharacters)
}

struct PasswordValidator: Validator {
    var rules: ValidationRules<String> {
        AllowIfEquals("Super secret")

        DenyIfContainsInvalidCharacters(allowedCharacters: .allowedPasswordCharacters)
            .message { characters in
                let list = characters.map { "\"\($0)\"" }.joined(separator: ", ")
                return "Characters \(list) are not allowed"
            }

        DenyIfContainsTooFewCharactersFromSet(.decimalDigits, minimum: 2)
            .message("Must contain at least 2 numbers")

        DenyIfContainsTooFewCharactersFromSet(.uppercaseLetters, minimum: 1)
            .message("Must contain at least 1 uppercase letter")

        DenyIfPartOfSet<String>(.bannedPasswords)
            .message { _, rule in
                return "Can't be part of the banned password list (\(rule.set.sorted().joined(separator: ", "))"
            }

        Property(\String.count) {
            DenyIf("Length must not be even") { $0 % 2 == 0 }

            DenyIfTooSmall(minimum: 8)
                .message { count, rule in
                    return "Must be at least \(rule.minimum) characters long (was \(count))"
                }
        }

        AlwaysAllow<String>()
    }
}

final class ValidTests: XCTestCase {
    func testInvalidCharacters() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "Hello😂123", lazy: false)
        XCTAssertDenies(results)
        let errors = results.all.errors
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].message, "Characters \"😂\" are not allowed")
        XCTAssertEqual(errors[0].location.line, 19)
    }

    func testTooFewDecimals() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "Hello1Hello", lazy: false)
        XCTAssertDenies(results)
        let errors = results.all.errors
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].message, "Must contain at least 2 numbers")
        XCTAssertEqual(errors[0].location.line, 25)
    }

    func testNoCapitals() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "hello123hello", lazy: false)
        XCTAssertDenies(results)
        let errors = results.all.errors
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].message, "Must contain at least 1 uppercase letter")
        XCTAssertEqual(errors[0].location.line, 28)
    }

    func testEven() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "Hello1234hello", lazy: false)
        XCTAssertDenies(results)
        let errors = results.all.errors
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].message, "Length must not be even")
        XCTAssertEqual(errors[0].location.line, 37)
    }

    func testTooSmall() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "H123l", lazy: false)
        XCTAssertDenies(results)
        let errors = results.all.errors
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].message, "Must be at least 8 characters long (was 5)")
        XCTAssertEqual(errors[0].location.line, 39)
    }

    func testValid() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "H123Password!")
        XCTAssertAllows(results)
    }
}

func XCTAssertDenies<T>(_ results: @autoclosure () -> Validation<T>,
                        _ message: @autoclosure () -> String = "",
                        file: StaticString = #file,
                        line: UInt = #line) {

    guard case .allow = results().verdict else { return }
    XCTFail(message(), file: file, line: line)
}

func XCTAssertAllows<T>(_ results: @autoclosure () -> Validation<T>,
                        _ message: @autoclosure () -> String = "",
                        file: StaticString = #file,
                        line: UInt = #line) {

    guard case .deny = results().verdict else { return }
    XCTFail(message(), file: file, line: line)
}
