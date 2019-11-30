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
    
    var currentRound: Int64?
    
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
                    if fetchedAccount.amount == account.amount &&
                        fetchedAccount.rewards == account.rewards &&
                        fetchedAccount.pendingRewards == account.pendingRewards &&
                        !fetchedAccount.areAssetsDifferent(than: account) {
                        return
                    }
                    
                    self.user?.updateAccount(fetchedAccount)
                }
            }
            
            completionOperation.addDependency(accountFetchOperation)
            self.queue.addOperation(accountFetchOperation)
        }
        
        self.queue.addOperation(completionOperation)
    }
    
    func fetchAccount(_ account: Account, then completion: EmptyHandler?) {
        let completionOperation = BlockOperation {
            completion?()
        }
        
        let accountFetchOperation = AccountFetchOperation(address: account.address, api: api)
        accountFetchOperation.onCompleted = { fetchedAccount, fetchError in
            if let fetchedAccount = fetchedAccount {
                if fetchedAccount.amount == account.amount &&
                    fetchedAccount.rewards == account.rewards &&
                    fetchedAccount.pendingRewards == account.pendingRewards &&
                    fetchedAccount.assetDetails.count == account.assetDetails.count {
                    return
                }
                
                self.user?.updateAccount(account)
            }
        }
        
        completionOperation.addDependency(accountFetchOperation)
        self.queue.addOperation(accountFetchOperation)
        self.queue.addOperation(completionOperation)
    }
    
    func waitForNextRoundAndFetchAccounts(round: Int64?, completion: ((Int64?) -> Void)?) {
        if let nextRound = round {
            self.api.waitRound(with: WaitRoundDraft(round: nextRound)) { roundDetailResponse in
                switch roundDetailResponse {
                case let .success(result):
                    let round = result.lastRound
                    self.fetchAllAccounts {
                        completion?(round)
                    }
                case .failure:
                    break
                }
            }
        } else {
            api.getTransactionParams { response in
                switch response {
                case .failure:
                    if let round = self.currentRound {
                        self.currentRound = round + 1
                    }
                case let .success(params):
                    self.currentRound = params.lastRound
                }
                
                guard let round = self.currentRound else {
                    completion?(nil)
                    return
                }
                
                self.api.waitRound(with: WaitRoundDraft(round: round)) { roundDetailResponse in
                    switch roundDetailResponse {
                    case let .success(result):
                        let round = result.lastRound
                        self.fetchAllAccounts {
                            completion?(round)
                        }
                    case .failure:
                        break
                    }
                }
            }
        }
    }
}
