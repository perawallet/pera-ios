//
//  AccountManager.swift
//  algorand
//
//  Created by Omer Emre Aslan on 5.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

class AccountManager {
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

extension AccountManager {
    func fetchAllAccounts(isVerifiedAssetsIncluded: Bool, completion: EmptyHandler?) {
        if isVerifiedAssetsIncluded {
            api.getVerifiedAssets { result in
                switch result {
                case let .success(list):
                    self.api.session.verifiedAssets = list.results
                    self.fetchAccounts(completion: completion)
                case .failure:
                    self.fetchAccounts(completion: completion)
                }
            }
        } else {
            fetchAccounts(completion: completion)
        }
    }
    
    private func fetchAccounts(completion: EmptyHandler?) {
        let completionOperation = BlockOperation {
            completion?()
        }
        
        guard let userAccounts = api.session.authenticatedUser?.accounts else {
            queue.addOperation(completionOperation)
            return
        }
        
        for account in userAccounts {
            let accountFetchOperation = AccountFetchOperation(accountInformation: account, api: api)
            accountFetchOperation.onCompleted = { fetchedAccount, fetchError in
                guard let fetchedAccount = fetchedAccount else {
                    return
                }
                
                fetchedAccount.name = account.name
                fetchedAccount.type = account.type
                fetchedAccount.ledgerDetail = account.ledgerDetail
                
                guard let currentAccount = self.api.session.account(from: fetchedAccount.address) else {
                    self.api.session.addAccount(fetchedAccount)
                    return
                }
                
                if fetchedAccount.amount == currentAccount.amount &&
                    fetchedAccount.rewards == currentAccount.rewards &&
                    !fetchedAccount.areAssetsDifferent(than: currentAccount) {
                    return
                }
                
                self.api.session.addAccount(fetchedAccount)
            }
            completionOperation.addDependency(accountFetchOperation)
            queue.addOperation(accountFetchOperation)
        }
        
        queue.addOperation(completionOperation)
    }
    
    func waitForNextRoundAndFetchAccounts(round: Int64?, completion: ((Int64?) -> Void)?) {
        if let nextRound = round {
            self.api.waitRound(with: WaitRoundDraft(round: nextRound)) { roundDetailResponse in
                switch roundDetailResponse {
                case let .success(result):
                    let round = result.lastRound
                    self.fetchAllAccounts(isVerifiedAssetsIncluded: false) {
                        completion?(round)
                    }
                case .failure:
                    self.getTransactionParamsAndFetchAccounts(completion: completion)
                }
            }
        } else {
            getTransactionParamsAndFetchAccounts(completion: completion)
        }
    }
    
    private func getTransactionParamsAndFetchAccounts(completion: ((Int64?) -> Void)?) {
        api.getTransactionParams { response in
            switch response {
            case .failure:
                self.currentRound = self.currentRound.map { $0 + 1 } ?? 0
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
                    self.fetchAllAccounts(isVerifiedAssetsIncluded: false) {
                        completion?(round)
                    }
                case .failure:
                    completion?(nil)
                }
            }
        }
    }
}
