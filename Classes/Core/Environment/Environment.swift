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
            return "http"
        case .prod:
            return "https"
        }
    }()
    
    lazy var serverHost: String = {
        switch target {
        case .staging:
            return "3.15.4.163:8080"
        case .prod:
            return "indexer.algorand.network:8443"
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
    
    lazy var serverToken: String = {
        switch target {
        case .staging:
            return "402049a2fde425a3e0e81b41c4c32fd70104544caee916ec86adea955f04c14b"
        case .prod:
            return "0f24cac92e5ead6afbcf389e0ade28bb609d24ca6687359f342748c68d6cf9b2"
        }
    }()
    
    lazy var algorandNodeName: String = {
        switch target {
        case .staging:
            return "node-settings-default-test-node-name".localized
        case .prod:
            return "node-settings-default-node-name".localized
        }
    }()
    
    private let target: AppTarget
    
    private init() {
        #if PRODUCTION
        target = .prod
        #else
        target = .staging
        #endif
    }
}
