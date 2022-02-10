// Copyright 2022 Pera Wallet, LDA

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
//   ALGAPIBase.swift

import Foundation
import MacaroonApplication
import MacaroonUtils
import MagpieAlamofire
import MagpieCore

final class ALGAPIBase {
    private(set) var algodToken: String?
    private(set) var indexerToken: String?
    private(set) var network: ALGAPI.Network = .mainnet

    func setupNetworkBase(_ network: ALGAPI.Network) -> String {
        self.network = network
        let node = network == .mainnet ? mainNetNode : testNetNode
        algodToken = node.algodToken
        indexerToken = node.indexerToken
        return node.algodAddress
    }
}

extension ALGAPIBase {
    enum Base {
        case algod(ALGAPI.Network)
        case indexer(ALGAPI.Network)
        case mobile
        case algoExplorer

        init?(_ base: String, network: ALGAPI.Network) {
            if base.isAlgodApiBase {
                self = .algod(network)
            } else if base.isIndexerApiBase {
                self = .indexer(network)
            } else if base.isMobileApiBase {
                self = .mobile
            } else if base.isAlgoExplorerApiBase {
                self = .algoExplorer
            } else {
                return nil
            }
        }

        var value: String {
            switch self {
            case let .algod(network):
                if network == .testnet {
                    return Environment.current.testNetAlgodApi
                } else {
                    return Environment.current.mainNetAlgodApi
                }
            case let .indexer(network):
                if network == .testnet {
                    return Environment.current.testNetIndexerApi
                } else {
                    return Environment.current.mainNetIndexerApi
                }
            case .mobile:
                return Environment.current.mobileApi
            case .algoExplorer:
                return Environment.current.algoExplorerApi
            }
        }
    }
}

fileprivate extension String {
    var isAlgodApiBase: Bool {
        return self == Environment.current.testNetAlgodApi || self == Environment.current.mainNetAlgodApi
    }

    var isIndexerApiBase: Bool {
        return self == Environment.current.testNetIndexerApi || self == Environment.current.mainNetIndexerApi
    }

    var isMobileApiBase: Bool {
        return self == Environment.current.mobileApi
    }

    var isAlgoExplorerApiBase: Bool {
        return self == Environment.current.algoExplorerApi
    }
}

extension EndpointBuilder {
    @discardableResult
    func base(_ someBase: ALGAPIBase.Base) -> Self {
        return base(someBase.value)
    }
}
