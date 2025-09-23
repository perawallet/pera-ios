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
//  QRResolver.swift

import Foundation
import pera_wallet_core

protocol QRResolver {
    func resolve(
        qrString: String,
        qrStringData: Data,
        context: QRResolutionContext
    ) -> QRResolutionResult?
}

struct QRResolutionContext {
    let canReadWCSession: Bool
    let deeplinkConfig: DeeplinkConfig
    let peraConnect: PeraConnect
    let featureFlagService: FeatureFlagServicing
}

enum QRResolutionResult {
    case walletConnect(preferences: WalletConnectSessionCreationPreferences)
    case backup(parameters: QRBackupParameters)
    case text(qrText: QRText)
    case externalDestination(destination: DiscoverExternalDestination)
    case liquidAuth(url: URL)
    case error(error: QRScannerError, resetHandler: EmptyHandler?)
}

class BaseQRResolver: QRResolver {
    var nextResolver: QRResolver?
    
    func resolve(
        qrString: String,
        qrStringData: Data,
        context: QRResolutionContext
    ) -> QRResolutionResult? {
        if let result = handleResolution(qrString: qrString, qrStringData: qrStringData, context: context) {
            return result
        }
        return nextResolver?.resolve(qrString: qrString, qrStringData: qrStringData, context: context)
    }
    
    func handleResolution(
        qrString: String,
        qrStringData: Data,
        context: QRResolutionContext
    ) -> QRResolutionResult? {
        // Override in subclasses
        return nil
    }
} 
