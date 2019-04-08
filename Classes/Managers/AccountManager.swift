//
//  AccountManager.swift
//  algorand
//
//  Created by Omer Emre Aslan on 5.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

class AccountManager {
    var user: User?
    let api: API
    
    let queue: OperationQueue
    
    init(api: API) {
        self.api = api
        self.queue = OperationQueue()
        self.queue.name = "AccountFetchOperation"
        self.queue.maxConcurrentOperationCount = 1
    }
}

// MARK: - API
extension AccountManager {
    func fetchAllAccounts(completion: EmptyHandler?) {
        let completionOperation = BlockOperation {
            completion?()
        }
        
        for account in user?.accounts ?? [] {
            let accountFetchOperation = AccountFetchOperation(address: account.address, api: api)
            accountFetchOperation.onCompleted = { fetchedAccount, fetchError in
                if let fetchedAccount = fetchedAccount {
                    account.update(withAccount: fetchedAccount)
                    self.user?.updateAccount(account)
                }
            }
            
            completionOperation.addDependency(accountFetchOperation)
            self.queue.addOperation(accountFetchOperation)
        }
        
        self.queue.addOperation(completionOperation)
    }
    
    func fetchAccount(_ account: Account,
                      then completion: EmptyHandler?) {
        let completionOperation = BlockOperation {
            completion?()
        }
        
        let accountFetchOperation = AccountFetchOperation(address: account.address, api: api)
        accountFetchOperation.onCompleted = { fetchedAccount, fetchError in
            if let fetchedAccount = fetchedAccount {
                account.update(withAccount: fetchedAccount)
                self.user?.updateAccount(account)
            }
        }
        
        completionOperation.addDependency(accountFetchOperation)
        self.queue.addOperation(accountFetchOperation)
        self.queue.addOperation(completionOperation)
    }
}
