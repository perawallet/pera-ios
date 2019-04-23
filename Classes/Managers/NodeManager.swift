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
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Node.creationDate), ascending: true)
        
        let completionOperation = BlockOperation {
            completion?(false)
        }
        
        if let session = api.session, session.isDefaultNodeActive() {
            let localNodeOperation = self.localNodeOperation(completion: completion)
            
            completionOperation.addDependency(localNodeOperation)
            self.queue.addOperation(localNodeOperation)
        }
        
        let nodeResult = Node.fetchAllSyncronous(
            entity: Node.entityName,
            with: NSPredicate(format: "isActive == %@", NSNumber(value: true)),
            sortDescriptor: sortDescriptor
        )
        
        switch nodeResult {
        case let .results(objects):
            for case let node as Node in objects {
                let nodeHealthOperation = NodeHealthOperation(node: node, api: api)
                nodeHealthOperation.onCompleted = { isHealthy in
                    guard let address = node.address, let token = node.token else {
                        return
                    }
                    
                    if isHealthy {
                        self.api.cancelAllEndpoints()
                        
                        self.api.base = address
                        self.api.token = token
                        
                        completion?(true)
                        self.queue.cancelAllOperations()
                    }
                }
                
                completionOperation.addDependency(nodeHealthOperation)
                self.queue.addOperation(nodeHealthOperation)
            }
        default:
            break
        }
        
        self.queue.addOperation(completionOperation)
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
