// Copyright 2023 Pera Wallet, LDA

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

typealias WCSessionSupportedMethod = String
typealias WCSessionSupportedEvent = String

struct WCSessionConnectionDraft {
    let image: URL?
    let dappName: String
    let dappURL: URL?
    let isApproved: Bool
    let supportedMethods: Set<WCSessionSupportedMethod>?
    let supportedEvents: Set<WCSessionSupportedEvent>?
    let requestedChains: [ALGAPI.Network]?

    init(session: WalletConnectSession) {
        image = session.dAppInfo.peerMeta.icons.first
        dappName =  session.dAppInfo.peerMeta.name
        dappURL = session.dAppInfo.peerMeta.url
        isApproved = session.dAppInfo.approved ?? false
        supportedMethods = WCSession.supportedMethods
        supportedEvents = WCSession.supportedEvents
        let chain = ALGAPI.Network(chainID: session.dAppInfo.chainId)
        requestedChains = chain.unwrap { [ $0 ] }
    }
    
    init(sessionProposal: WalletConnectV2SessionProposal) {
        image = sessionProposal.proposer.icons.first.unwrap(URL.init)
        dappName = sessionProposal.proposer.name
        dappURL = URL(string: sessionProposal.proposer.url)
        isApproved = false

        let requiredNamespaces = sessionProposal.requiredNamespaces["algorand"]
        supportedMethods = requiredNamespaces?.methods
        supportedEvents = requiredNamespaces?.events

        let requestedChains = requiredNamespaces?.chains
        self.requestedChains = requestedChains?.compactMap(ALGAPI.Network.init(blockchain:))
    }
}

extension ALGAPI.Network {
    /// <note> WC V1
    init?(chainID: Int?) {
        switch chainID {
        case algorandWalletConnectChainID,
             algorandWalletConnectTestNetChainID:
            self = .testnet
        case algorandWalletConnectChainID,
             algorandWalletConnectMainNetChainID:
            self = .mainnet
        default:
            return nil
        }
    }

    /// <note> WC V2
    init?(blockchain: Blockchain) {
        let chainReference = blockchain.reference
        self.init(chainReference: chainReference)
    }

    init?(chainReference: String) {
        switch chainReference {
        case "wGHE2Pwdvd7S12BL5FaOP20EGYesN73k":
            self = .mainnet
        case "SGO1GKSzyE7IEPItTxCByw9x8FmnrCDe":
            self = .testnet
        default:
            return nil
        }
    }
}

extension WCSession {
    static let supportedMethods: Set<WCSessionSupportedMethod> = [
        "algo_signData",
        "algo_signTxn"
    ]
    static let supportedEvents: Set<WCSessionSupportedEvent> = [
        "accountChanged"
    ]
}
