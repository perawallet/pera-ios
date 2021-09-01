// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol MultidelegationPublisher: AnyObject {
    associatedtype SomeDelegator: Delegator

    var delegators: [ObjectIdentifier: SomeDelegator] { get set }

    func add(delegate: SomeDelegator.Delegate)
    func remove(delegate: SomeDelegator.Delegate)
}

extension MultidelegationPublisher {
    public func add(delegate: SomeDelegator.Delegate) {
        if let validDelegate = delegate as? AnyObject {
            let id = ObjectIdentifier(validDelegate)
            delegators[id] = SomeDelegator(delegate)
        }
    }

    public func remove(delegate: SomeDelegator.Delegate) {
        if let validDelegate = delegate as? AnyObject {
            let id = ObjectIdentifier(validDelegate)
            delegators[id] = nil
        }
    }

    public func removeAllDelegates() {
        delegators.removeAll()
    }

    public func notifyDelegates(_ notifier: (SomeDelegator.Delegate) -> Void) {
        delegators.forEach {
            if let delegate = $0.value.delegate {
                notifier(delegate)
            } else {
                delegators[$0.key] = nil
            }
        }
    }
}

public protocol Delegator {
    associatedtype Delegate

    /// <note> It should be defined as a weak variable for no retain cycle.
    var delegate: Delegate? { get }

    init(_ delegate: Delegate)
}
