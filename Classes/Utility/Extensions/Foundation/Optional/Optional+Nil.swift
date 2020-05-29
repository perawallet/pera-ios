//
//  Optional+Nil.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        guard let strongSelf = self else {
            return true
        }
        return strongSelf.isEmptyOrBlank
    }
}

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    var nonEmpty: Wrapped? {
        isNilOrEmpty ? nil : self
    }
}

extension Optional {
    func unwrap(or someValue: Wrapped) -> Wrapped {
        return self ?? someValue
    }

    func unwrap<T>(either transform: (Wrapped) -> T, or someValue: T) -> T {
        return map(transform) ?? someValue
    }

    func unwrap<T>(either keyPath: KeyPath<Wrapped, T>, or someValue: T) -> T {
        return unwrap(either: { $0[keyPath: keyPath] }, or: someValue)
    }

    func unwrap<T>(either keyPath: KeyPath<Wrapped, T?>, or someValue: T) -> T {
        return unwrap(either: { $0[keyPath: keyPath] ?? someValue }, or: someValue)
    }

    func unwrapIfPresent<T>(either transform: (Wrapped) -> T, or someValue: T? = nil) -> T? {
        return map(transform) ?? someValue
    }

    func unwrapIfPresent<T>(either transform: (Wrapped) -> T?, or someValue: T? = nil) -> T? {
        return map(transform) ?? someValue
    }

    func unwrapConditionally(where predicate: (Wrapped) -> Bool) -> Wrapped? {
        return unwrap(either: { predicate($0) ? $0 : nil }, or: nil)
    }
}

extension Optional {
    func `continue`(ifPresent operation: (Wrapped) -> Void, else elseOperation: (() -> Void)? = nil) {
        if let value = self {
            operation(value)
        } else {
            elseOperation?()
        }
    }
}
