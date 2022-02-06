
import Foundation

public protocol ValidationResultWhichAllowsOptionalMessage {}
extension MaybeAllow: ValidationResultWhichAllowsOptionalMessage {}
extension MaybeDeny: ValidationResultWhichAllowsOptionalMessage {}
extension FinalValidation: ValidationResultWhichAllowsOptionalMessage {}
