//
//  AtomicWrapper.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.04.2019.
//

/// <reference> https://www.objc.io/blog/2018/12/18/atomic-variables/

import Foundation

public final class AtomicWrapper<Value> {
    private var wrapped: Value

    private let queue = DispatchQueue(label: "com.hipo.magpie.queue.atomics")

    init(value: Value) {
        self.wrapped = value
    }

    func getValue() -> Value {
        return queue.sync {
            self.wrapped
        }
    }

    func setValue(_ transform: (inout Value) -> Void) {
        queue.sync {
            transform(&self.wrapped)
        }
    }
}

extension AtomicWrapper: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(wrapped)"
    }
}
