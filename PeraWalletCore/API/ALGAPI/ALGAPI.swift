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
//  API.swift

import Foundation
import MacaroonApplication
import MacaroonUtils
import MagpieAlamofire
import MagpieCore

public final class ALGAPI: API {
    public let session: Session
    private let featureFlagService: FeatureFlagServicing

    /// <todo>
    /// NOP!
    public var _interceptor: ALGAPIInterceptor {
        interceptor as! ALGAPIInterceptor
    }

    public var network: Network {
        _interceptor.network
    }
    public var isTestNet: Bool {
        _interceptor.isTestNet
    }
    public var deviceId: String? {
        session.authenticatedUser?.getDeviceId(on: network)
    }
    public var useAssetDetailV2: Bool {
        featureFlagService.isEnabled(.assetDetailV2Enabled)
    }

    public init(session: Session, featureFlagService: FeatureFlagServicing, networkMonitor: NetworkMonitor? = nil) {
        self.session = session
        self.featureFlagService = featureFlagService

        super.init(
            base: AppEnvironment.current.serverApi,
            networking: AlamofireNetworking(),
            interceptor: ALGAPIInterceptor(),
            networkMonitor: networkMonitor
        )

        self.ignoresResponseWhenEndpointsFailedFromUnauthorizedRequest = false

        debug {
            enableLogsInConsole()
        }
    }
}

extension ALGAPI {
    public func setupNetworkBase(_ network: ALGAPI.Network) {
        base = _interceptor.setupNetworkBase(network)
    }
}

extension ALGAPI {
    public enum Network: String {
        case testnet = "testnet"
        case mainnet = "mainnet"

        /// WC v1
        public var allowedChainIDs: [Int] {
            switch self {
            case .testnet:
                return [
                    algorandWalletConnectV1ChainID,
                    algorandWalletConnectV1TestNetChainID
                ]
            case .mainnet:
                return [
                    algorandWalletConnectV1ChainID,
                    algorandWalletConnectV1MainNetChainID
                ]
            }
        }

        /// WC v2
        public var allowedChainReference: String {
            switch self {
            case .testnet:
                return algorandWalletConnectV2TestNetChainReference
            case .mainnet:
                return algorandWalletConnectV2MainNetChainReference
            }
        }

        public var isMainnet: Bool {
            self == .mainnet
        }
        
        public var isTestnet: Bool {
            self == .testnet
        }
        
        public static func == (lhs: Network, rhs: Network) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
}
