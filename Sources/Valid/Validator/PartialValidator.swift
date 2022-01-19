
import Foundation

public protocol PartialValidator {
    associatedtype Input

    @ValidationRulesBuilder
    var rules: PartialValidationRules<Input> { get }
}
