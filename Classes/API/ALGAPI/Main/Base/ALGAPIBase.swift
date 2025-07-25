// Copyright 2022-2025 Pera Wallet, LDA

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
        case mobileV1(ALGAPI.Network)
        case mobileV2(ALGAPI.Network)

        init?(_ base: String, network: ALGAPI.Network) {
            if base.isAlgodApiBase {
                self = .algod(network)
            } else if base.isIndexerApiBase {
                self = .indexer(network)
            } else if base.isMobileApiV1Base {
                self = .mobileV1(network)
            } else if base.isMobileApiV2Base {
                self = .mobileV2(network)
            } else {
                return nil
            }
        }

        var value: String {
            switch self {
            case let .algod(network):
                if network == .testnet {
                    return AppEnvironment.current.testNetAlgodApi
                } else {
                    return AppEnvironment.current.mainNetAlgodApi
                }
            case let .indexer(network):
                if network == .testnet {
                    return AppEnvironment.current.testNetIndexerApi
                } else {
                    return AppEnvironment.current.mainNetIndexerApi
                }
            case let .mobileV1(network):
                if network == .testnet {
                    return AppEnvironment.current.testNetMobileAPIV1
                } else {
                    return AppEnvironment.current.mainNetMobileAPIV1
                }
            case let .mobileV2(network):
                if network == .testnet {
                    return AppEnvironment.current.testNetMobileAPIV2
                } else {
                    return AppEnvironment.current.mainNetMobileAPIV2
                }
            }
        }
    }
}

fileprivate extension String {
    var isAlgodApiBase: Bool {
        return self == AppEnvironment.current.testNetAlgodApi || self == AppEnvironment.current.mainNetAlgodApi
    }

    var isIndexerApiBase: Bool {
        return self == AppEnvironment.current.testNetIndexerApi || self == AppEnvironment.current.mainNetIndexerApi
    }

    var isMobileApiV1Base: Bool {
        return self == AppEnvironment.current.testNetMobileAPIV1 || self == AppEnvironment.current.mainNetMobileAPIV1
    }

    var isMobileApiV2Base: Bool {
        return self == AppEnvironment.current.testNetMobileAPIV2 || self == AppEnvironment.current.mainNetMobileAPIV2
    }
}

extension EndpointBuilder {
    @discardableResult
    func base(_ someBase: ALGAPIBase.Base) -> Self {
        return base(someBase.value)
    }
}
