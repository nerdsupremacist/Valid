
import Foundation

public protocol PartialValidator {
    associatedtype Input

    var rules: PartialValidationRules<Input> { get }
}
