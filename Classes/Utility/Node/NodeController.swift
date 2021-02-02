//
//  NodeController.swift

import Foundation

class NodeController {
    let api: AlgorandAPI
    let queue: OperationQueue
    
    init(api: AlgorandAPI) {
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
        let token = Environment.current.algodToken
        let localNodeHealthOperation = NodeHealthOperation(address: address, token: token, api: api)
        
        localNodeHealthOperation.onCompleted = { isHealthy in
            if isHealthy {
                self.setNewNode(with: address, and: token, then: completion)
            }
        }
        
        return localNodeHealthOperation
    }
    
    private func setNewNode(with address: String, and token: String, then completion: BoolHandler?) {
         api.cancelEndpoints()
         api.base = address
         api.algodToken = token
         completion?(true)
         queue.cancelAllOperations()
     }
}
