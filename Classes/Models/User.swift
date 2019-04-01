//
//  User.swift
//  algorand
//
//  Created by Omer Emre Aslan on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class User: Mappable {
    private(set) var accounts: [Account] = []
    fileprivate var defaultAccountAddress: String?
    
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
        syncronize()
    }
    
    func removeAccount(_ account: Account) {
        guard let index = index(of: account) else {
            return
        }
        
        accounts.remove(at: index)
        syncronize()
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
    
    func updateAccount(_ account: Account) {
        guard let index = index(of: account) else {
            return
        }
        
        accounts[index] = account
        syncronize()
    }
    
    fileprivate func syncronize() {
        guard UIApplication.shared.appConfiguration?.session.authenticatedUser != nil else {
            return
        }
        
        UIApplication.shared.appConfiguration?.session.authenticatedUser = self
    }
    
    func setDefaultAccount(_ account: Account) {
        self.defaultAccountAddress = account.address
        syncronize()
    }
    
    func defaultAccount() -> Account? {
        guard let address = defaultAccountAddress else {
            return nil
        }
        
        return accountFrom(address: address)
    }
    
    func account(address: String) -> Account? {
        return accountFrom(address: address)
    }
}

// MARK: - Helpers
extension User {
    fileprivate func accountFrom(address: String) -> Account? {
        return accounts.filter{ return $0.address == address }.first
    }
}

// MARK: - Codable
extension User: Encodable {
}
