import Foundation

/// Wrapper for a value protected by a serial DispatchQueue
@propertyWrapper
final class Atomic<Value> {
    // MARK: Properties

    private lazy var queue = DispatchQueue(label: "atomic.queue.\(String(describing: type(of: self)))")
    private var value: Value

    // MARK: Initialization

    init(wrappedValue value: Value) {
        self.value = value
    }

    // MARK: Properties

    var wrappedValue: Value {
        queue.sync { value }
    }

    var projectedValue: Atomic<Value> {
        self
    }

    /// Mutates the underlying value within a lock. Mostly useful for mutating the contents of `Atomic` wrappers around collections
    /// - Parameter block: The block to execute to mutate the value
    func mutate(_ block: (inout Value) -> Void) {
        queue.sync {
            block(&value)
        }
    }
}
