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
    // MARK: Singleton
    private static let instance = Environment()
    
    // MARK: Variables
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
        case .staging, .prod:
            return "indexer.algorand.network:8081"
        }
    }()
    
    lazy var coinlistHost: String = {
        switch target {
        case .staging, .prod:
            return "demo.coinlist.co"
        }
    }()
    
    lazy var serverApi: String = {
        let api = "\(serverSchema)://\(serverHost)"
        return api
    }()
    
    lazy var cointlistApi: String = {
        let api = "https://\(coinlistHost)"
        return api
    }()
    
    lazy var serverToken: String = {
       "0f24cac92e5ead6afbcf389e0ade28bb609d24ca6687359f342748c68d6cf9b2"
    }()
    
    private let target: AppTarget
    
    // MARK: Initialization
    private init() {
        #if APPSTORE
        target = .prod
        #else
        target = .staging
        #endif
    }
}
