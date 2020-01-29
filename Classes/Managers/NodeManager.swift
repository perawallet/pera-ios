//
//  NodeManager.swift
//  algorand
//
//  Created by Omer Emre Aslan on 18.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

class NodeManager {
    let api: API
    
    let queue: OperationQueue
    
    init(api: API) {
        self.api = api
        self.queue = OperationQueue()
        self.queue.name = "NodeFetchOperation"
        self.queue.maxConcurrentOperationCount = 1
    }
}

// MARK: - API
extension NodeManager {
    func checkNodes(completion: BoolHandler?) {
        let completionOperation = BlockOperation {
            completion?(false)
        }
        
        let localNodeOperation = self.localNodeOperation(completion: completion)
        completionOperation.addDependency(localNodeOperation)
        queue.addOperation(localNodeOperation)
        queue.addOperation(completionOperation)
    }
    
    fileprivate func localNodeOperation(completion: BoolHandler?) -> NodeHealthOperation {
        let address = Environment.current.serverApi
        let token = Environment.current.serverToken
        
        let localNodeHealthOperation = NodeHealthOperation(
            address: address,
            token: token,
            api: api
        )
        
        localNodeHealthOperation.onCompleted = { isHealthy in
            if isHealthy {
                self.api.cancelAllEndpoints()
                
                self.api.base = address
                self.api.token = token
                
                completion?(true)
                self.queue.cancelAllOperations()
            }
        }
        
        return localNodeHealthOperation
    }
}
