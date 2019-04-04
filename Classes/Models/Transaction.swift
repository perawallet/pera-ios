//
//  Transaction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

// TODO: Created transaction struct for mocking accounts home view. Should be replaced with codable model.

struct Transaction: Codable {
    
    let identifier: String
    let accountName: String
    let date: Date
    let amount: Double
    let title: String
}

// MARK: Equatable

extension Transaction: Equatable {
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
