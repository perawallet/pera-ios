// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

extension Bool {
    public func execute(true trueOperation: () -> Void, false falseOperation: () -> Void) {
        self ? trueOperation() : falseOperation()
    }

    public func transform<T>(true trueOperation: () -> T, false falseOperation: () -> T) -> T {
        return self ? trueOperation() : falseOperation()
    }
}
