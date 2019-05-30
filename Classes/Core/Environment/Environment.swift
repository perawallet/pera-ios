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
        case .staging, .prod:
            return "https"
        }
    }()
    
    lazy var serverHost: String = {
        switch target {
        case .staging, .prod:
            return "indexer.algorand.network:8443"
        }
    }()
    
    lazy var coinlistHost: String = {
        switch target {
        case .staging:
            return "demo.coinlist.co"
        case .prod:
            return "coinlist.co"
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
    
    lazy var coinlistClientId: String = {
        switch target {
        case .staging:
            return "a06e76e5011e6a094739270c8820f6e44a02f9a81d93ab32f5fc584fab31b5f2"
        case .prod:
            return "7fb1221754c8aa17172fdef40d76f4478b1edbba3349f3641928e89349459efe"
        }
    }()
    
    lazy var coinlistClientSecret: String = {
        switch target {
        case .staging:
            return "e5d43226691ee9d3a89b7d65a5cb7cf5de5680cf703e9c17b9b7b87253ca21a7"
        case .prod:
            return "e5d43226691ee9d3a89b7d65a5cb7cf5de5680cf703e9c17b9b7b87253ca21a7"
        }
    }()
    
    lazy var serverToken: String = {
       "0f24cac92e5ead6afbcf389e0ade28bb609d24ca6687359f342748c68d6cf9b2"
    }()
    
    private let target: AppTarget
    
    // MARK: Initialization
    private init() {
        #if PRODUCTION
        target = .prod
        #else
        target = .staging
        #endif
    }
}
