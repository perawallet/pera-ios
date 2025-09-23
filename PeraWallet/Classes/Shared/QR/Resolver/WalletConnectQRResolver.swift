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
//  WalletConnectQRResolver.swift

import Foundation
import pera_wallet_core

class WalletConnectQRResolver: BaseQRResolver {
    override func handleResolution(
        qrString: String,
        qrStringData: Data,
        context: QRResolutionContext
    ) -> QRResolutionResult? {
        guard context.peraConnect.isValidSession(qrString) else {
            return nil
        }
        
        guard context.canReadWCSession else {
            return .error(
                error: .invalidData,
                resetHandler: nil
            )
        }
        
        var isAccountMultiselectionEnabled = true
        var mandatoryAccount: String?
        
        if let queryString = qrString.split(separator: "?").last {
            let parameters = queryString.split(separator: "&")
            mandatoryAccount = parseQrCodeQueryParameter(
                parameters: parameters,
                key: Constants.Cards.selectedAccount.rawValue
            )
            if let singleAccountValue = parseQrCodeQueryParameter(
                parameters: parameters,
                key: Constants.Cards.singleAccount.rawValue
            ) {
                isAccountMultiselectionEnabled = (singleAccountValue != "true")
            }
        }
        
        let preferences = WalletConnectSessionCreationPreferences(
            session: qrString,
            prefersConnectionApproval: true,
            isAccountMultiselectionEnabled: isAccountMultiselectionEnabled,
            mandotaryAccount: mandatoryAccount
        )
        
        return .walletConnect(preferences: preferences)
    }
    
    private func parseQrCodeQueryParameter(
        parameters: [Substring],
        key: String
    ) -> String? {
        guard let param = parameters.first(
            where: {
                $0.hasPrefix("\(key)=")
            })
        else {
            return nil
        }
        let keyValue = param.split(separator: "=")
        return keyValue[safe: 1].map { String($0) }
    }
} 
