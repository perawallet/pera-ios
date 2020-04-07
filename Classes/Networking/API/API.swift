//
//  API.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class API: Magpie {
    var token: String?
    let session: Session
    
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
    
    func algorandAuthenticatedHeaders() -> Headers {
        guard let token = token else {
            return sharedHttpHeaders
        }
        
        var headers = sharedHttpHeaders
        headers.set(.custom("X-Algo-API-Token", .some(token)))
        return headers
    }
    
    func nodeHealthHeaders(for nodeToken: String) -> Headers {
        var headers = sharedHttpHeaders
        headers.set(.custom("X-Algo-API-Token", .some(nodeToken)))
        return headers
    }
}
