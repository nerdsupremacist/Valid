
import Foundation

class ValidationContext<Input> {
    private let value: Input
    let lazy: Bool
    private var diagnostics: Diagnostics
    private var children: [BasicValidationResults<Input>.AnyChild]
    private(set) var checks: [Check]

    init(value: Input, lazy: Bool = true) {
        self.value = value
        self.lazy = lazy
        self.diagnostics = Diagnostics(successes: [], warnings: [], errors: [])
        self.children = []
        self.checks = []
    }

    func check(_ check: Check) {
        self.checks.append(check)
    }

    func success(_ diagnostic: Diagnostic) {
        diagnostics.successes.append(diagnostic)
    }

    func error(_ diagnostic: Diagnostic) {
        diagnostics.errors.append(diagnostic)
    }

    func warning(_ diagnostic: Diagnostic) {
        diagnostics.warnings.append(diagnostic)
    }

    func validate(using validator: InternalValidator<Input>) async -> ValidationResult {
        return await validator.validate(input: value, on: self)
    }

    func validateSubGroup(name: String? = nil,
                          using validator: InternalValidator<Input>,
                          as type: Any.Type,
                          location: Location) async -> ValidationResult {
        let context = ValidationContext(value: value, lazy: lazy)
        let result = await context.validate(using: validator)
        diagnostics = diagnostics + context.diagnostics
        let group = Check.Group(name: name ?? String(describing: type), checks: context.checks, validation: result)
        check(Check(type: type, kind: .group(group), location: location))
        return result
    }

}
