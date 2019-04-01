//
//  User.swift
//  algorand
//
//  Created by Omer Emre Aslan on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class User: Mappable {
    private var uniqueIdentifier: String?
    
    private(set) var accounts: [Account] = []
    var defaultAccount: String?
    var image: Data?
    
    private(set) var contacts: [User] = []
    
    init(accounts: [Account]) {
        self.accounts = accounts
    }
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

// MARK: - API
extension User {
    func addAccount(_ account: Account) {
        accounts.append(account)
    }
    
    func removeAccount(_ account: Account) {
        guard let index = index(of: account) else {
            return
        }
        
        accounts.remove(at: index)
    }
    
    func index(of account: Account) -> Int? {
        guard let index = accounts.firstIndex(of: account) else {
            return nil
        }
        
        return index
    }
    
    func account(at index: Int) -> Account? {
        guard index < accounts.count else {
            return nil
        }
        
        return accounts[index]
    }
    
    func addContact(_ contact: User) {
        contacts.append(contact)
    }
    
    func removeContact(_ contact: User) {
        guard let index = index(of: contact) else {
            return
        }
        
        contacts.remove(at: index)
    }
    
    func index(of contact: User) -> Int? {
        guard let index = contacts.firstIndex(of: contact) else {
            return nil
        }
        
        return index
    }
    
    func contact(at index: Int) -> User? {
        guard index < contacts.count else {
            return nil
        }
        
        return contacts[index]
    }
}

// MARK: - Codable
extension User: Encodable {
}

// MARK: - Equatable

extension User: Equatable {
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uniqueIdentifier == rhs.uniqueIdentifier
    }
}
