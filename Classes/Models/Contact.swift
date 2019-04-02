//
//  Contact.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class Contact: Mappable {
    
    private var identifier: String?
    
    var address: String?
    var image: Data?
    var name: String?
    
    private(set) var transactions: [Transaction] = []
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

// MARK: API

extension Contact {
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    func removeTransaction(_ transaction: Transaction) {
        guard let index = index(of: transaction) else {
            return
        }
        
        transactions.remove(at: index)
    }
    
    func index(of transaction: Transaction) -> Int? {
        guard let index = transactions.firstIndex(of: transaction) else {
            return nil
        }
        
        return index
    }
    
    func transaction(at index: Int) -> Transaction? {
        guard index < transactions.count else {
            return nil
        }
        
        return transactions[index]
    }
}

// MARK: Codable

extension Contact: Encodable {
}

// MARK: Equatable

extension Contact: Equatable {
    
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
