
import Foundation

public struct ValidationResults<Value>: ValidationResultsProtocol {
    private class BaseStorage {
        func value() -> Value {
            fatalError()
        }

        func local() -> Diagnostics {
            fatalError()
        }

        func all() -> Diagnostics {
            fatalError()
        }

        func child<T>(_ keyPath: KeyPath<Value, T>) -> ValidationResults<T> {
            fatalError()
        }
    }

    private final class Storage<R : ValidationResultsProtocol>: BaseStorage where R.Value == Value {
        let results: R

        init(_ results: R) {
            self.results = results
        }

        override func value() -> Value {
            return results.value
        }

        override func local() -> Diagnostics {
            return results.local
        }

        override func all() -> Diagnostics {
            return results.all
        }

        override func child<T>(_ keyPath: KeyPath<Value, T>) -> ValidationResults<T> {
            return results[keyPath]
        }
    }

    private let storage: BaseStorage

    init<R : ValidationResultsProtocol>(_ results: R) where R.Value == Value {
        self.storage = Storage(results)
    }

    public var value: Value {
        return storage.value()
    }

    public var local: Diagnostics {
        return storage.local()
    }

    public var all: Diagnostics {
        return storage.all()
    }

    public subscript<T>(keyPath: KeyPath<Value, T>) -> ValidationResults<T> {
        return storage.child(keyPath)
    }
}
