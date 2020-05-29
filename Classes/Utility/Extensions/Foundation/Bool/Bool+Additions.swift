//
//  Bool+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

extension Bool {
    func `continue`(isTrue trueOperation: () -> Void, isFalse falseOperation: () -> Void) {
        self ? trueOperation() : falseOperation()
    }

    func `return`<T>(isTrue trueTransform: () -> T, isFalse falseTransform: () -> T) -> T {
        return self ? trueTransform() : falseTransform()
    }
}
