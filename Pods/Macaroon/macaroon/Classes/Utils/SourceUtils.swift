// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

/// <mark> Error
public func mc_crash(
    _ error: Error
) -> Never {
    crash(error)
}

public func crash(
    _ error: Swift.Error
) -> Never {
    fatalError(
        error.localizedDescription
    )
}

/// <mark> GCD
public func asyncMain(
    execute: @escaping () -> Void
) {
    DispatchQueue.main.async(
        execute: execute
    )
}

public func asyncMain(
    workItem: DispatchWorkItem
) {
    DispatchQueue.main.async(
        execute: workItem
    )
}

public func asyncMain<T: AnyObject>(
    _ instance: T,
    execute: @escaping (T) -> Void
) {
    asyncMain {
        [weak instance] in

        guard let strongInstance = instance else {
            return
        }

        execute(
            strongInstance
        )
    }
}

public func asyncMainAfter(
    duration: TimeInterval,
    execute: @escaping () -> Void
) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + duration,
        execute: execute
    )
}

public func asyncMainAfter(
    duration: TimeInterval,
    workItem: DispatchWorkItem
) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + duration,
        execute: workItem
    )
}

public func asyncMainAfter<T: AnyObject>(
    _ instance: T,
    duration: TimeInterval,
    execute: @escaping (T) -> Void
) {
    asyncMainAfter(
        duration: duration
    ) { [weak instance] in

        guard let strongInstance = instance else {
            return
        }

        execute(
            strongInstance
        )
    }
}

public func asyncBackground(
    qos: DispatchQoS.QoSClass = .background,
    execute: @escaping () -> Void
) {
    DispatchQueue.global(
        qos: qos
    ).async(
        execute: execute
    )
}

public func asyncBackground<T: AnyObject>(
    _ instance: T,
    qos: DispatchQoS.QoSClass = .background,
    execute: @escaping (T) -> Void
) {
    asyncBackground(
        qos: qos
    ) { [weak instance] in

        guard let strongInstance = instance else {
            return
        }

        execute(
            strongInstance
        )
    }
}

//// <mark> Debug
public func debug(
    _ execute: () -> Void
) {
    #if DEBUG
    execute()
    #endif
}

public func release(
    _ execute: () -> Void
) {
    #if !DEBUG
    execute()
    #endif
}
