
import Foundation

public protocol Validator {
    associatedtype Input

    @ValidationRulesBuilder
    var rules: ValidationRules<Input> { get }
}
