//
//  AccountFetchOperation.swift
//  algorand
//
//  Created by Omer Emre Aslan on 5.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation
import UIKit

typealias AccountFetchHandler = (Account?, Error?) -> Void

class AccountFetchOperation: AsyncOperation {
    let address: String
    let api: API
    
    var onStarted: EmptyHandler?
    var onCompleted: AccountFetchHandler?
    
    init(address: String, api: API) {
        self.address = address
        self.api = api
        super.init()
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        api.fetchAccount(with: AccountFetchDraft(publicKey: address)) { response in
            switch response {
            case .success(let account):
                if account.isThereAnyDifferentAsset() {
                    self.fetchAssets(for: account)
                } else {
                    self.onCompleted?(account, nil)
                }
            case .failure(let error):
                self.onCompleted?(nil, error)
            }
            self.finish()
        }
        
        onStarted?()
    }
    
    func finish(with error: Error? = nil) {
        state = .finished
    }
}

extension AccountFetchOperation {
    private func fetchAssets(for account: Account) {
        guard let assets = account.assets else {
            return
        }
        
        for (index, _) in assets {
            guard let id = Int64(index) else {
                continue
            }
            self.api.getAssetDetails(with: AssetFetchDraft(assetId: index)) { assetResponse in
                switch assetResponse {
                case .success(let assetDetail):
                    self.composeAssetDetail(assetDetail, of: account, with: id)
                case .failure(let error):
                    self.removeAssetDetail(with: id, from: account, for: error)
                }
            }
        }
    }
    
    private func composeAssetDetail(_ assetDetail: AssetDetail, of account: Account, with id: Int64) {
        guard let assets = account.assets else {
            return
        }
        
        var assetDetail = assetDetail
        assetDetail.id = Int64(id)
        setVerifiedIfNeeded(&assetDetail, with: id)
        account.assetDetails.append(assetDetail)
        
        if assets.count == account.assetDetails.count {
            self.onCompleted?(account, nil)
        }
    }
    
    private func setVerifiedIfNeeded(_ assetDetail: inout AssetDetail, with id: Int64) {
        if let verifiedAssets = api.session.verifiedAssets,
            verifiedAssets.contains(where: { verifiedAsset -> Bool in
                verifiedAsset.id == id
            }) {
            assetDetail.isVerified = true
        }
    }
    
    private func removeAssetDetail(with id: Int64, from account: Account, for error: Error) {
        guard let assets = account.assets else {
            return
        }
        
        account.removeAsset(Int64(id))
        
        if assets.count == account.assetDetails.count {
            self.onCompleted?(nil, error)
        }
    }
}
