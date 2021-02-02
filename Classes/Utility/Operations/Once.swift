//
//  Once.swift

import Foundation

class Once {
    typealias Operation = () -> Void

    private var isCompleted = false

    init() { }

    func execute(_ operation: Operation) {
        if !isCompleted {
            operation()
            isCompleted = true
        }
    }
}
