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
//  AppDeeplinkQRResolver.swift

import Foundation
import pera_wallet_core

class AppDeeplinkQRResolver: BaseQRResolver {
    override func handleResolution(
        qrString: String,
        qrStringData: Data,
        context: QRResolutionContext
    ) -> QRResolutionResult? {
        guard let url = URL(string: qrString),
              AppDeeplinkParser.isAppBasedDeeplink(url) else {
            return nil
        }
        
        // Parse the app-based deeplink
        let deeplinkQR = DeeplinkQR(url: url)
        guard let qrText = deeplinkQR.qrText() else {
            return .error(
                error: .jsonSerialization,
                resetHandler: nil
            )
        }
        
        if qrText.mode == .walletConnect,
           let walletConnectUrl = qrText.walletConnectUrl {
            let walletConnectResolver = WalletConnectQRResolver()
            return walletConnectResolver.resolve(
                qrString: walletConnectUrl,
                qrStringData: walletConnectUrl.data(using: .utf8) ?? Data(),
                context: context
            )
        }
        
        return .text(qrText: qrText)
    }
}
