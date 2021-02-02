//
//  Bool+Additions.swift

import Foundation

extension Bool {
    func `continue`(isTrue trueOperation: () -> Void, isFalse falseOperation: () -> Void) {
        self ? trueOperation() : falseOperation()
    }

    func `return`<T>(isTrue trueTransform: () -> T, isFalse falseTransform: () -> T) -> T {
        return self ? trueTransform() : falseTransform()
    }
}
