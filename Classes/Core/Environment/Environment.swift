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
            return "r2.algorand.network:4181"
        }
    }()
    
    lazy var serverApi: String = {
        let api = "\(serverSchema)://\(serverHost)"
        return api
    }()
    
    lazy var serverToken: String = {
       "af1cf81622d34a9e25c11277b9a591525f0a66611850050f5102030598cce8d7"
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
