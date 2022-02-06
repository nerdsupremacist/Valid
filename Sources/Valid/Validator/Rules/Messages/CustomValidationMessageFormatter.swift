
import Foundation

public protocol CustomValidationMessageFormatter {
    associatedtype Input

    func message(from input: Input) -> String
}
