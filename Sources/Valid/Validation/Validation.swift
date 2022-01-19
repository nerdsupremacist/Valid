
import Foundation

public struct Check {
    public struct Group {
        public let name: String
        public let checks: [Check]
        public let validation: ValidationResult
    }

    public indirect enum Kind {
        case validation(ValidationResult)
        case group(Group)
    }

    public let type: Any.Type
    public let kind: Kind
    public let location: Location
}

public struct Validation<Value>: ValidationResultsProtocol {
    public enum Verdict {
        case allow(message: String?)
        case deny(message: String?)
    }

    public let verdict: Verdict
    public let checks: [Check]
    private let results: BasicValidationResults<Value>

    init(verdict: Verdict, checks: [Check], results: BasicValidationResults<Value>) {
        self.verdict = verdict
        self.checks = checks
        self.results = results
    }

    public var all: Diagnostics {
        return results.all
    }

    public var local: Diagnostics {
        return results.local
    }

    public var value: Value {
        return results.value
    }

    public subscript<T>(keyPath: KeyPath<Value, T>) -> ValidationResults<T> {
        return results[keyPath]
    }
}
