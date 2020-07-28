//
//  API.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class API: Magpie {
    var algodToken: String?
    var indexerToken: String?
    var network: BaseNetwork = .mainnet
    var mobileApiBase: String = Environment.current.mobileApi
    let session: Session
    
    var isTestNet: Bool {
        return network == .testnet
    }
    
    init(session: Session) {
        self.session = session
        
        if #available(iOS 12, *) {
            super.init(
                base: Environment.current.serverApi,
                networking: AlamofireNetworking(),
                networkMonitor: NWNetworkMonitor()
            )
        } else {
            super.init(
                base: Environment.current.serverApi,
                networking: AlamofireNetworking(),
                networkMonitor: AlamofireNetworkMonitor()
            )
        }
        
        authorize()
        
        sharedJsonBodyEncodingStrategy = JSONBodyEncodingStrategy(date: JSONEncoder.DateEncodingStrategy.shared)
        sharedModelDecodingStrategy = ModelDecodingStrategy(date: JSONDecoder.DateDecodingStrategy.shared)
        sharedErrorModelDecodingStrategy = ModelDecodingStrategy(date: JSONDecoder.DateDecodingStrategy.shared)
        
        runIfRelease {
            logFilter = .none()
        }
    }
    
    @available(*, unavailable)
    required init(base: String, networking: Networking, networkMonitor: NetworkMonitor? = nil) {
        fatalError("init(base:networking:networkMonitor:) has not been implemented")
    }
}

extension API {
    func authorize() {
        base = Environment.current.serverApi
    }
    
    var algodBase: String {
        if network == .testnet {
            return Environment.current.testNetAlgodApi
        } else {
            return Environment.current.mainNetAlgodApi
        }
    }
    
    var indexerBase: String {
        if network == .testnet {
            return Environment.current.testNetIndexerApi
        } else {
            return Environment.current.mainNetIndexerApi
        }
    }
    
    func algodAuthenticatedHeaders() -> Headers {
        guard let token = algodToken else {
            return sharedHttpHeaders
        }
        
        var headers = sharedHttpHeaders
        headers.set(.custom("X-Algo-API-Token", .some(token)))
        return headers
    }
    
    func algodBinaryAuthenticatedHeaders() -> Headers {
        guard let token = algodToken else {
            return sharedHttpHeaders
        }
        
        var headers = sharedHttpHeaders
        headers.set(.contentType("application/x-binary"))
        headers.set(.custom("X-Algo-API-Token", .some(token)))
        return headers
    }
    
    func indexerAuthenticatedHeaders() -> Headers {
        guard let token = indexerToken else {
            return sharedHttpHeaders
        }
        
        var headers = sharedHttpHeaders
        headers.set(.custom("X-Indexer-API-Token", .some(token)))
        return headers
    }
    
    func mobileApiHeaders() -> Headers {
        var headers = sharedHttpHeaders
        headers.set(.custom("algorand-network", .some(network.rawValue)))
        return headers
    }
    
    func nodeHealthHeaders(for nodeToken: String) -> Headers {
        var headers = sharedHttpHeaders
        headers.set(.custom("X-Algo-API-Token", .some(nodeToken)))
        return headers
    }
}

extension API {
    func setupEnvironment(for network: API.BaseNetwork) {
        self.network = network
        let node = network == .mainnet ? mainNetNode : testNetNode
        
        base = node.algodAddress
        algodToken = node.algodToken
        indexerToken = node.indexerToken
    }
}

extension API {
    enum BaseNetwork: String {
        case testnet = "testnet"
        case mainnet = "mainnet"
    }
}
