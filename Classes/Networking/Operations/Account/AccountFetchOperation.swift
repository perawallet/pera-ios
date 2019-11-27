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
    
    // MARK: Initialization
    init(address: String, api: API) {
        self.address = address
        self.api = api
        super.init()
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        let draft = AccountFetchDraft(publicKey: address)
        
        api.fetchAccount(with: draft) { response in
            switch response {
            case .success(let account):
                if account.isThereAnyDifferentAsset() {
                    if let assets = account.assets {
                        for (index, _) in assets {
                            self.api.getAssetDetails(with: AssetFetchDraft(assetId: "\(index)")) { assetResponse in
                                switch assetResponse {
                                case .success(let assetDetail):
                                    assetDetail.index = index
                                    account.assetDetails.append(assetDetail)
                                    self.onCompleted?(account, nil)
                                case .failure(let error):
                                    self.onCompleted?(nil, error)
                                }
                            }
                        }
                    }
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
