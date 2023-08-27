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

//   WCConnectionSessionDraft.swift

import Foundation

struct WCConnectionSessionDraft {
    let image: URL?
    let dappName: String
    let dappURL: URL
    let isApproved: Bool
    
    init(session: WalletConnectSession) {
        image = session.dAppInfo.peerMeta.icons.first
        dappName =  session.dAppInfo.peerMeta.name
        dappURL = session.dAppInfo.peerMeta.url
        isApproved = session.dAppInfo.approved ?? false
    }
    
    init(sessionProposal: WalletConnectV2SessionProposal) {
        image = URL(string: sessionProposal.proposer.icons.first!)
        dappName = sessionProposal.proposer.name
        dappURL = URL(string: sessionProposal.proposer.url)!
        isApproved = false
    }
}
