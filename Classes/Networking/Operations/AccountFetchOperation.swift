//
//  AccountFetchOperation.swift
//  algorand
//
//  Created by Omer Emre Aslan on 5.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation
import UIKit

typealias StartClosure = () -> Void
typealias CompletionClosure = (Account?, Error?) -> Void

class AccountFetchOperation: AsyncOperation {
    
    let address: String
    let api: API
    
    var onStarted: StartClosure?
    var onCompleted: CompletionClosure?
    
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
                self.onCompleted?(account, nil)
            case .failure(let error):
                self.onCompleted?(nil, error)
            }
            
            self.finish()
        }
        
        onStarted?()
    }
    
    // MARK: Public
    
    func finish(with error: Error? = nil) {
        state = .finished
    }
}
