//
//  ApplicationTargetManager.swift
//  algorand
//
//  Created by Omer Emre Aslan on 20.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

enum ApplicationEnvironment {
    case production
    case staging
}

class ApplicationTargetManager {
    static let shared: ApplicationTargetManager = ApplicationTargetManager()
    
    private init() {}
    
    lazy var environment: ApplicationEnvironment = {
        #if PRODUCTION
        return .production
        #else
        return .staging
        #endif
    }()
}
