//
//  Once.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

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
