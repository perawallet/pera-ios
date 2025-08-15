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

//   WCSessionConnectionDraft.swift

import Foundation
import WalletConnectUtils

public typealias WCSessionSupportedMethod = String
public typealias WCSessionSupportedEvent = String

public struct WCSessionConnectionDraft {
    public let image: URL?
    public let dappName: String
    public let dappURL: URL?
    public let isApproved: Bool
    public let supportedMethods: Set<WCSessionSupportedMethod>?
    public let supportedEvents: Set<WCSessionSupportedEvent>?
    public let requestedChains: [ALGAPI.Network]?

    public init(session: WalletConnectSession) {
        image = session.dAppInfo.peerMeta.icons.first
        dappName =  session.dAppInfo.peerMeta.name
        dappURL = session.dAppInfo.peerMeta.url
        isApproved = session.dAppInfo.approved ?? false
        supportedMethods = WCSession.supportedMethods
        supportedEvents = WCSession.supportedEvents

        let chainID = session.dAppInfo.chainId
        switch chainID {
        case algorandWalletConnectV1ChainID:
            requestedChains = [ .mainnet, .testnet ]
        case algorandWalletConnectV1TestNetChainID:
            requestedChains = [ .testnet ]
        case algorandWalletConnectV1MainNetChainID:
            requestedChains = [ .mainnet ]
        default:
            requestedChains = nil
        }
    }
    
    public init(sessionProposal: WalletConnectV2SessionProposal) {
        image = sessionProposal.proposer.icons.first.unwrap(URL.init)
        dappName = sessionProposal.proposer.name
        dappURL = URL(string: sessionProposal.proposer.url)
        isApproved = false

        let requiredNamespaces = sessionProposal.requiredNamespaces[WalletConnectNamespaceKey.algorand]
        supportedMethods = requiredNamespaces?.methods
        supportedEvents = requiredNamespaces?.events

        let requestedChains = requiredNamespaces?.chains
        self.requestedChains = requestedChains?.compactMap(ALGAPI.Network.init(blockchain:))
    }
}

extension ALGAPI.Network {
    /// <note> WC V2
    public init?(blockchain: Blockchain) {
        let chainReference = blockchain.reference
        self.init(chainReference: chainReference)
    }

    public init?(chainReference: String) {
        switch chainReference {
        case algorandWalletConnectV2MainNetChainReference:
            self = .mainnet
        case algorandWalletConnectV2TestNetChainReference:
            self = .testnet
        default:
            return nil
        }
    }
}

extension WCSession {
    public static let supportedMethods: Set<WCSessionSupportedMethod> = [
        WalletConnectMethod.arbitraryDataSign.rawValue,
        WalletConnectMethod.transactionSign.rawValue
    ]
    public static let supportedEvents: Set<WCSessionSupportedEvent> = [
        WalletConnectEvent.accountsChanged.rawValue
    ]
}

public enum WalletConnectNamespaceKey {
    public static let algorand = "algorand"
}
