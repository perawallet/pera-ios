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
//  QRResolverManager.swift

import Foundation
import pera_wallet_core

class QRResolverManager {
    private let resolverChain: QRResolver
    
    init() {
        // Set up the chain of responsibility
        // Order matters: most specific resolvers first, general ones later
        let walletConnectResolver = WalletConnectQRResolver()
        let liquidAuthResolver = LiquidAuthQRResolver()
        let appDeeplinkResolver = AppDeeplinkQRResolver()
        let backupResolver = BackupQRResolver()
        let textResolver = TextQRResolver()
        let urlResolver = URLQRResolver()
        let coinbaseResolver = CoinbaseQRResolver()
        let addressResolver = AddressQRResolver()
        
        walletConnectResolver.nextResolver = liquidAuthResolver
        liquidAuthResolver.nextResolver = appDeeplinkResolver
        appDeeplinkResolver.nextResolver = backupResolver
        backupResolver.nextResolver = textResolver
        textResolver.nextResolver = urlResolver
        urlResolver.nextResolver = coinbaseResolver
        coinbaseResolver.nextResolver = addressResolver
        
        resolverChain = walletConnectResolver
    }
    
    func resolveQR(
        qrString: String,
        qrStringData: Data,
        context: QRResolutionContext,
        cameraResetHandler: @escaping EmptyHandler
    ) -> QRResolutionResult {
        if let result = resolverChain.resolve(
            qrString: qrString,
            qrStringData: qrStringData,
            context: context
        ) {
            if case .error(let error, _) = result {
                return .error(error: error, resetHandler: cameraResetHandler)
            }
            return result
        }
        
        return .error(error: .jsonSerialization, resetHandler: cameraResetHandler)
    }
} 
