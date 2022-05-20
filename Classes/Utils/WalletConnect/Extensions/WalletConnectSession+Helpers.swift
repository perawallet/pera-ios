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
//   WalletConnectSession+Helpers.swift

import UIKit

let algorandWalletConnectChainID = 4160

extension WalletConnectSession {
    func getClientMeta() -> ClientMeta {
        /// <note>
        /// No need for localization since it won't be translated and sent to the Dapp.
        /// <todo>
        /// Let's find a way to not use the current instance of `ALGAppTarget` directly here when refactoring the wallet connect
        /// integration.
        let metaConfig = ALGAppTarget.current.walletConnectConfig.meta
        return ClientMeta(
            name: metaConfig.name,
            description: metaConfig.description,
            icons: metaConfig.icons,
            url: metaConfig.url
        )
    }

    func getApprovedWalletConnectionInfo(for account: String) -> WalletInfo {
        return WalletInfo(
            approved: true,
            accounts: [account],
            chainId: algorandWalletConnectChainID,
            peerId: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
            peerMeta: getClientMeta()
        )
    }

    func getDeclinedWalletConnectionInfo() -> WalletInfo {
        return WalletInfo(
            approved: false,
            accounts: [],
            chainId: algorandWalletConnectChainID,
            peerId: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
            peerMeta: getClientMeta()
        )
    }

    func toWCSession() -> WCSession {
        return WCSession(
            urlMeta: WCURLMeta(wcURL: url),
            peerMeta: WCPeerMeta(dappInfo: dAppInfo),
            walletMeta: WCWalletMeta(walletInfo: walletInfo, dappInfo: dAppInfo),
            date: Date()
        )
    }
}
