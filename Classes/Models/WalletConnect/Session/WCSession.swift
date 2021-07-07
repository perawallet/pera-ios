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
//   WCSession.swift

import Foundation

class WCSession: Codable {
    let urlMeta: WCURLMeta
    let peerMeta: WCPeerMeta
    let walletMeta: WCWalletMeta?
    let date: Date

    init(urlMeta: WCURLMeta, peerMeta: WCPeerMeta, walletMeta: WCWalletMeta?, date: Date) {
        self.urlMeta = urlMeta
        self.peerMeta = peerMeta
        self.walletMeta = walletMeta
        self.date = date
    }

    var sessionBridgeValue: WalletConnectSession {
        WalletConnectSession(url: urlMeta.wcURL, dAppInfo: peerMeta.dappInfo, walletInfo: walletMeta?.walletInfo)
    }
}
