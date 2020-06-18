//
//  Environment.swift
//  algorand
//
//  Created by Omer Emre Aslan on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

private enum AppTarget {
    case staging, prod
}

class Environment {
    
    private static let instance = Environment()
    
    static var current: Environment {
        return instance
    }
    
    lazy var serverSchema: String = {
        switch target {
        case .staging:
            return testNetSchema
        case .prod:
            return mainNetSchema
        }
    }()
    
    lazy var isTestNet = target == .staging
    
    lazy var testNetSchema = "http"
    lazy var testNetHost = "18.191.127.220"
    lazy var testNetAlgodPort = "8080"
    lazy var testNetAlgodToken = "04f2acd11eab4c16942e0298efd7f1c9150ec812b6495bbf4c7127f763c4c4c5"
    lazy var testNetIndexerPort = "8980"
    lazy var testNetIndexerToken = "MCjDYTMPmjaHhclwTuVVPnhvcbSHkLdnnmYVxPEbkNMeKbJt"
    lazy var testNetAlgodApi = "\(testNetSchema)://\(testNetHost):\(testNetAlgodPort)"
    lazy var testNetIndexerApi = "\(testNetSchema)://\(testNetHost):\(testNetIndexerPort)"
    
    lazy var mainNetSchema = "https"
    lazy var mainNetHost = "indexer.algorand.network"
    lazy var mainNetAlgodPort = "8443"
    lazy var mainNetAlgodToken = "0f24cac92e5ead6afbcf389e0ade28bb609d24ca6687359f342748c68d6cf9b2"
    lazy var mainNetIndexerPort = "8443"
    lazy var mainNetIndexerToken = "0f24cac92e5ead6afbcf389e0ade28bb609d24ca6687359f342748c68d6cf9b2"
    lazy var mainNetAlgodApi = "\(mainNetSchema)://\(mainNetHost):\(mainNetAlgodPort)"
    lazy var mainNetIndexerApi = "\(mainNetSchema)://\(mainNetHost):\(mainNetIndexerToken)"
    
    lazy var serverHost: String = {
        switch target {
        case .staging:
            return testNetHost
        case .prod:
            return mainNetHost
        }
    }()
    
    lazy var binanceHost = "api.binance.com"
    
    lazy var mobileHost = "mobile-api.algorand.com"
    
    lazy var serverApi: String = {
        let api = "\(serverSchema)://\(serverHost)"
        return api
    }()
    
    lazy var binanceApi: String = {
        let api = "https://\(binanceHost)"
        return api
    }()
    
    lazy var mobileApi: String = {
        switch target {
        case .staging:
            return "https://staging.\(mobileHost)"
        case .prod:
            return "https://\(mobileHost)"
        }
    }()
    
    lazy var testNetMobileApi = "https://staging.\(mobileHost)"
    
    lazy var mainNetMobileApi = "https://\(mobileHost)"
    
    lazy var serverToken: String = {
        switch target {
        case .staging:
            return testNetAlgodToken
        case .prod:
            return mainNetAlgodToken
        }
    }()
    
    lazy var termsAndServicesUrl = "https://www.algorand.com/wallet-disclaimer"
    
    private let target: AppTarget
    
    private init() {
        #if PRODUCTION
        target = .prod
        #else
        target = .staging
        #endif
    }
}
