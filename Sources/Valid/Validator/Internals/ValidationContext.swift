
import Foundation

final actor ValidationContext<Input> {
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

    func validate<T>(_ keyPath: KeyPath<Input, T>,
                     name: String?,
                     using validator: InternalValidator<T>,
                     as type: Any.Type,
                     location: Location) async -> ValidationResult {

        let childValue = value[keyPath: keyPath]
        let context = ValidationContext<T>(value: childValue, lazy: lazy)
        let result = await context.validate(using: validator)
        let child = await BasicValidationResults<Input>.Child(keyPath: keyPath, results: context.build())
        children.append(child)
        let group = await Check.Group(name: name ?? keyPath._kvcKeyPathString ?? String(describing: type),
                                      checks: context.checks,
                                      validation: result)
        check(Check(type: type, kind: .group(group), location: location))
        return result
    }

    func validateSubGroup(name: String? = nil,
                          using validator: InternalValidator<Input>,
                          as type: Any.Type,
                          location: Location) async -> ValidationResult {
        let context = ValidationContext(value: value, lazy: lazy)
        let result = await context.validate(using: validator)
        diagnostics = await diagnostics + context.diagnostics
        let group = await Check.Group(name: name ?? String(describing: type), checks: context.checks, validation: result)
        check(Check(type: type, kind: .group(group), location: location))
        return result
    }

    func validateForSome<T>(using validator: InternalValidator<T>, as type: Any.Type, location: Location) async -> ValidationResult where Input == T? {
        guard let value = value else {
            check(Check(type: type, kind: .validation(.skip), location: location))
            return .skip
        }

        let context = ValidationContext<T>(value: value, lazy: lazy)
        let result = await context.validate(using: validator)
        diagnostics = await diagnostics + context.diagnostics
        checks.append(contentsOf: await context.checks)
        return result
    }

    func build() -> BasicValidationResults<Input> {
        return BasicValidationResults(value: value, local: diagnostics, children: children)
    }
}
