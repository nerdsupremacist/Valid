
import Foundation

public protocol Validator {
    associatedtype Input

    var rules: ValidationRules<Input> { get }
}
