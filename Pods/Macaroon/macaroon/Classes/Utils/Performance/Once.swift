// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public class Once {
    public typealias Operation = () -> Void

    private var isCompleted = false

    public init() { }

    public func execute(_ operation: Operation) {
        if !isCompleted {
            operation()
            isCompleted = true
        }
    }
}
