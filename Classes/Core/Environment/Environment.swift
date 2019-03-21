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
            return "localhost:8080"
        }
    }()
    
    lazy var serverApi: String = {
        let api = "\(serverSchema)://\(serverHost)"
        return api
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
