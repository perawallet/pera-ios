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
            case .success(let accountWrapper):
                if accountWrapper.account.isThereAnyDifferentAsset() {
                    self.fetchAssets(for: accountWrapper.account)
                } else {
                    self.onCompleted?(accountWrapper.account, nil)
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
            onCompleted?(account, nil)
            return
        }
        
        var removedAssetCount = 0
        for asset in assets {
            self.api.getAssetDetails(with: AssetFetchDraft(assetId: "\(asset.id)")) { assetResponse in
                switch assetResponse {
                case .success(let assetDetailResponse):
                    self.composeAssetDetail(
                        assetDetailResponse.assetDetail,
                        of: account,
                        with: asset.id,
                        removedAssetCount: &removedAssetCount
                    )
                case .failure:
                    removedAssetCount += 1
                    account.removeAsset(asset.id)
                    if assets.count == account.assetDetails.count + removedAssetCount {
                        self.onCompleted?(account, nil)
                    }
                }
            }
        }
    }
    
    private func composeAssetDetail(_ assetDetail: AssetDetail, of account: Account, with id: Int64, removedAssetCount: inout Int) {
        guard let assets = account.assets else {
            onCompleted?(account, nil)
            return
        }
        
        var assetDetail = assetDetail
        setVerifiedIfNeeded(&assetDetail, with: id)
        account.assetDetails.append(assetDetail)
        
        if assets.count == account.assetDetails.count + removedAssetCount {
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
}
