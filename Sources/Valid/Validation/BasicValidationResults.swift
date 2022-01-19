
import Foundation

final class BasicValidationResults<Value>: ValidationResultsProtocol {
    class AnyChild {
        func children() -> [PartialKeyPath<Value> : Diagnostics] {
            fatalError()
        }
    }

    final class Child<T>: AnyChild {
        private let keyPath: KeyPath<Value, T>
        private let results: BasicValidationResults<T>

        init(keyPath: KeyPath<Value, T>, results: BasicValidationResults<T>) {
            self.keyPath = keyPath
            self.results = results
        }

        override func children() -> [PartialKeyPath<Value> : Diagnostics] {
            let current: [PartialKeyPath<Value> : Diagnostics] = [keyPath : results.local]
            let children = results.children.compactMapKeys { keyPath.appendingPartialKeyPath(path: $0) }
            return current.merging(children) { $0 + $1 }
        }
    }

    let value: Value
    let local: Diagnostics
    fileprivate let children: [PartialKeyPath<Value> : Diagnostics]

    init(value: Value,
         local: Diagnostics,
         children: [PartialKeyPath<Value> : Diagnostics]) {

        self.value = value
        self.local = local
        self.children = children
    }

    convenience init(value: Value,
                     local: Diagnostics,
                     children: [AnyChild]) {

        let children = children.reduce([:]) { $0.merging($1.children()) { $0 + $1 } }
        self.init(value: value, local: local, children: children)
    }

    var all: Diagnostics {
        return children.values.reduce(local) { $0 + $1 }
    }

    subscript<T>(keyPath: KeyPath<Value, T>) -> ValidationResults<T> {
        return ValidationResults(ChildValidationResults(parent: self, keyPath: keyPath))
    }
}

final class ChildValidationResults<Parent, Value>: ValidationResultsProtocol {
    private let parent: BasicValidationResults<Parent>
    private let keyPath: KeyPath<Parent, Value>

    var value: Value {
        return parent.value[keyPath: keyPath]
    }

    var local: Diagnostics {
        return parent.children[keyPath] ?? Diagnostics(successes: [], warnings: [], errors: [])
    }

    var all: Diagnostics {
        return local
    }

    init(parent: BasicValidationResults<Parent>, keyPath: KeyPath<Parent, Value>) {
        self.parent = parent
        self.keyPath = keyPath
    }

    subscript<T>(keyPath: KeyPath<Value, T>) -> ValidationResults<T> {
        return parent[self.keyPath.appending(path: keyPath)]
    }
}

extension Dictionary {

    fileprivate func compactMapKeys<T : Hashable>(_ transform: (Key) throws -> T?) rethrows -> [T : Value] {
        return try reduce(into: [:]) { dictionary, element in
            let (key, value) = element
            guard let newKey = try transform(key) else { return }
            dictionary[newKey] = value
        }
    }

}

extension KeyPath {

    fileprivate func appendingPartialKeyPath(path: PartialKeyPath<Value>) -> PartialKeyPath<Root> {
        let root = self as PartialKeyPath<Root>
        return root.appending(path: path)!
    }

}
