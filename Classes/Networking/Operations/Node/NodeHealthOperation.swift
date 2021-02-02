//
//  NodeHealthOperation.swift

import Foundation

class NodeHealthOperation: AsyncOperation {
    
    let address: String?
    let token: String?
    let api: AlgorandAPI
    
    var onStarted: EmptyHandler?
    var onCompleted: BoolHandler?
    
    init(node: Node, api: AlgorandAPI) {
        self.address = node.address
        self.token = node.token
        self.api = api
        super.init()
    }
    
    init(address: String?, token: String?, api: AlgorandAPI) {
        self.address = address
        self.token = token
        self.api = api
        super.init()
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        guard let address = self.address,
            let token = self.token else {
                self.onCompleted?(false)
                self.state = .finished
            return
        }

        let nodeTestDraft = NodeTestDraft(address: address, token: token)
        api.checkNodeHealth(with: nodeTestDraft) { isHealthy in
            self.onCompleted?(isHealthy)
            self.state = .finished
        }
        
        onStarted?()
    }
}
