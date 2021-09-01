// Copyright © 2019 hipolabs. All rights reserved.

/// <src>
/// https://www.vadimbulavin.com/swift-atomic-properties-with-property-wrappers/

import Foundation

@propertyWrapper
public final class Atomic<Value> {
    public var wrappedValue: Value {
        get {
            queue.sync {
                value
            }
        }
        set {
            fatalError(
                """
                Do not directly call `setter`.
                Instead call `setValue(_:)` to guarantee the atomic setter for all types.
                """
            )
        }
    }
    public var projectedValue: Atomic<Value> {
        return self
    }

    private var value: Value

    private let queue: DispatchQueue

    public init(
        wrappedValue: Value,
        identifier: String
    ) {
        self.value = wrappedValue
        self.queue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier.nonNil).\(identifier)")
    }

    public func modify(
        _ transform: (inout Value) -> Void
    ) {
        queue.sync {
            transform(
                &value
            )
        }
    }
}
