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
//   WalletConnectSession+Helpers.swift

import UIKit

extension WalletConnectSession {
    func getClientMeta() -> ClientMeta {
        return ClientMeta(
            name: dAppInfo.peerMeta.name,
            description: dAppInfo.peerMeta.description,
            icons: dAppInfo.peerMeta.icons,
            url: dAppInfo.peerMeta.url
        )
    }

    func getApprovedWalletConnectionInfo(for account: String) -> WalletInfo {
        return WalletInfo(
            approved: true,
            accounts: [account],
            chainId: walletInfo?.chainId ?? 4,
            peerId: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
            peerMeta: getClientMeta()
        )
    }

    func getDeclinedWalletConnectionInfo() -> WalletInfo {
        return WalletInfo(
            approved: false,
            accounts: [],
            chainId: walletInfo?.chainId ?? 4,
            peerId: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
            peerMeta: getClientMeta()
        )
    }
}
