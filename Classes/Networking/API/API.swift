//
//  API.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class AlgorandAPI: API {
    private lazy var application = HIPApplication()
    private lazy var device = HIPDevice()
    
    var algodToken: String?
    var indexerToken: String?
    var network: BaseNetwork = .mainnet
    var mobileApiBase: String = Environment.current.mobileApi
    let session: Session
    
    var isTestNet: Bool {
        return network == .testnet
    }
    
    let sharedHeaders: Headers = [AcceptHeader.json(), AcceptEncodingHeader.gzip(), ContentTypeHeader.json()]
    
    required init(
        session: Session,
        base: String,
        networking: Networking = AlamofireNetworking(),
        interceptor: APIInterceptor? = nil,
        networkMonitor: NetworkMonitor? = AlamofireNetworkMonitor()
    ) {
        self.session = session
        super.init(
            base: base,
            networking: networking,
            interceptor: interceptor,
            networkMonitor: networkMonitor
        )
        
        authorize()
    }
}

extension AlgorandAPI {
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
            return sharedHeaders
        }
        
        var headers = sharedHeaders
        headers.insert(CustomHeader(key: "X-Algo-API-Token", value: token))
        return headers
    }
    
    func algodBinaryAuthenticatedHeaders() -> Headers {
        guard let token = algodToken else {
            return sharedHeaders
        }
        
        var headers = sharedHeaders
        headers.insert(CustomHeader(key: "X-Algo-API-Token", value: token))
        headers.insert(CustomHeader(key: "Content-Type", value: "application/x-binary"))
        return headers
    }
    
    func indexerAuthenticatedHeaders() -> Headers {
        guard let token = indexerToken else {
            return sharedHeaders
        }
        
        var headers = sharedHeaders
        headers.insert(CustomHeader(key: "X-Indexer-API-Token", value: token))
        return headers
    }
    
    func mobileApiHeaders() -> Headers {
        var headers = sharedHeaders
        headers.insert(CustomHeader(key: "algorand-network", value: network.rawValue))
        headers.insert(AppNameHeader(application))
        headers.insert(AppPackageNameHeader(application))
        headers.insert(AppVersionHeader(application))
        headers.insert(ClientTypeHeader(device))
        headers.insert(DeviceOSVersionHeader(device))
        headers.insert(DeviceModelHeader(device))
        return headers
    }
    
    func nodeHealthHeaders(for nodeToken: String) -> Headers {
        var headers = sharedHeaders
        headers.insert(CustomHeader(key: "X-Algo-API-Token", value: nodeToken))
        return headers
    }
}

extension AlgorandAPI {
    func setupEnvironment(for network: AlgorandAPI.BaseNetwork) {
        self.network = network
        let node = network == .mainnet ? mainNetNode : testNetNode
        
        base = node.algodAddress
        algodToken = node.algodToken
        indexerToken = node.indexerToken
    }
}

extension AlgorandAPI {
    enum BaseNetwork: String {
        case testnet = "testnet"
        case mainnet = "mainnet"
    }
}
