//
//  NodeController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 18.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

class NodeController {
    let api: API
    let queue: OperationQueue
    
    init(api: API) {
        self.api = api
        self.queue = OperationQueue()
        self.queue.name = "NodeFetchOperation"
        self.queue.maxConcurrentOperationCount = 1
    }
}

extension NodeController {
    func checkNodeHealth(completion: BoolHandler?) {
        let completionOperation = BlockOperation {
            completion?(false)
        }
        
        let localNodeOperation = self.localNodeOperation(completion: completion)
        completionOperation.addDependency(localNodeOperation)
        queue.addOperation(localNodeOperation)
        queue.addOperation(completionOperation)
    }
    
    private func localNodeOperation(completion: BoolHandler?) -> NodeHealthOperation {
        let address = Environment.current.serverApi
        let token = Environment.current.serverToken
        let localNodeHealthOperation = NodeHealthOperation(address: address, token: token, api: api)
        
        localNodeHealthOperation.onCompleted = { isHealthy in
            if isHealthy {
                self.setNewNode(with: address, and: token, then: completion)
            }
        }
        
        return localNodeHealthOperation
    }
    
    private func setNewNode(with address: String, and token: String, then completion: BoolHandler?) {
         api.cancelAllEndpoints()
         api.base = address
         api.algodToken = token
         completion?(true)
         queue.cancelAllOperations()
     }
}
