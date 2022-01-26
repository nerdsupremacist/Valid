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

        DenyIfContainsTooFewCharactersFromSet(.uppercaseLetters, minimum: 1, message: "Must contain at least 1 uppercase letter")

        Property(\String.count) {
            DenyIf("Length must not be even") { $0 % 2 == 0 }

            DenyIfTooSmall(minimum: 8, message: "Must be at least 8 characters long")
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
        XCTAssertEqual(errors[0].location.line, 6)
    }

    func testTooFewDecimals() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "Hello1Hello", lazy: false)
        XCTAssertDenies(results)
        let errors = results.all.errors
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].message, "Must contain at least 2 numbers")
        XCTAssertEqual(errors[0].location.line, 12)
    }

    func testNoCapitals() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "hello123hello", lazy: false)
        XCTAssertDenies(results)
        let errors = results.all.errors
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].message, "Must contain at least 1 uppercase letter")
        XCTAssertEqual(errors[0].location.line, 14)
    }

    func testEven() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "Hello1234hello", lazy: false)
        XCTAssertDenies(results)
        let errors = results.all.errors
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].message, "Length must not be even")
        XCTAssertEqual(errors[0].location.line, 17)
    }

    func testTooSmall() async {
        let validator = PasswordValidator()
        let results = await validator.validate(input: "H123l", lazy: false)
        XCTAssertDenies(results)
        let errors = results.all.errors
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].message, "Must be at least 8 characters long")
        XCTAssertEqual(errors[0].location.line, 19)
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
