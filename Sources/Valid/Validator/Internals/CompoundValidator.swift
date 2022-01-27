
import Foundation

final class CompoundValidator<Input>: InternalValidator<Input> {
    let validators: [InternalValidator<Input>]

    init(validators: [InternalValidator<Input>]) {
        self.validators = validators
    }

    override func followed(by validator: InternalValidator<Input>) -> InternalValidator<Input> {
        if let validator = validator as? CompoundValidator {
            return CompoundValidator(validators: validators + validator.validators)
        }
        return CompoundValidator(validators: validators + [validator])
    }

    override func validate(input: Input, on context: ValidationContext<Input>) async -> ValidationResult {
        if context.lazy {
            for validator in validators {
                let result = await context.validate(using: validator)
                switch result {
                case .allow, .deny:
                    return result
                case .skip:
                    continue
                }
            }

            return .skip
        }

        let results = await validators.concurrentMap { await context.validate(using: $0) }
        for result in results {
            switch result {
            case .allow, .deny:
                return result
            case .skip:
                continue
            }
        }
        
        return .skip
    }
}

extension Sequence {
    fileprivate func concurrentMap<T>(transform: @escaping (Element) async throws -> T) async rethrows -> [T] {
        let tasks = map { element in
            Task {
                try await transform(element)
            }
        }

        return try await tasks.asyncMap { task in
            try await task.value
        }
    }
    func asyncMap<T>(transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
