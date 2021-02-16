// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  Environment.swift

import Foundation

private enum AppTarget {
    case staging, prod
}

class Environment {
    
    private static let instance = Environment()
    
    static var current: Environment {
        return instance
    }
    
    let appID = "1459898525"
    
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
    lazy var privacyPolicyUrl = "https://www.algorand.com/wallet-privacy-policy"
    
    private let target: AppTarget
    
    private init() {
        #if PRODUCTION
        target = .prod
        #else
        target = .staging
        #endif
    }
}
