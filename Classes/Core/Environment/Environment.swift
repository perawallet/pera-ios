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
    
    lazy var isTestNet = target == .staging
    
    lazy var schema = "https"
    lazy var algodToken = "0dw4Qu6ckPJTQY540Z0sEokH910KUWKjsf312fxNtTcVjw5UUhhlK4s4odcXIoEz"
    lazy var indexerToken = "KegWFLYQnBNVeP4oHCX64dObBk8VemzYdNqsnAOIxYQ8aqJLQTYeVDQyZNnx1PZA"
    
    lazy var testNetAlgodHost = "node-testnet.aws.algodev.network"
    lazy var testNetIndexerHost = "indexer-testnet.aws.algodev.network"
    lazy var testNetAlgodApi = "\(schema)://\(testNetAlgodHost)"
    lazy var testNetIndexerApi = "\(schema)://\(testNetIndexerHost)"
    
    lazy var mainNetAlgodHost = "node-mainnet.aws.algodev.network"
    lazy var mainNetIndexerHost = "indexer-mainnet.aws.algodev.network"
    lazy var mainNetAlgodApi = "\(schema)://\(mainNetAlgodHost)"
    lazy var mainNetIndexerApi = "\(schema)://\(mainNetIndexerHost)"
    
    lazy var serverHost: String = {
        switch target {
        case .staging:
            return testNetAlgodHost
        case .prod:
            return mainNetAlgodHost
        }
    }()
    
    lazy var binanceHost = "api.binance.com"
    
    lazy var mobileHost = "mobile-api.algorand.com"
    
    lazy var serverApi: String = {
        let api = "\(schema)://\(serverHost)"
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
