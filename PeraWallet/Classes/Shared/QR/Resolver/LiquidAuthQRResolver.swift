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
//  LiquidAuthQRResolver.swift

import Foundation
import UIKit
import pera_wallet_core

class LiquidAuthQRResolver: BaseQRResolver {
    override func handleResolution(
        qrString: String,
        qrStringData: Data,
        context: QRResolutionContext
    ) -> QRResolutionResult? {
        guard let url = URL(string: qrString),
              let scheme = url.scheme,
              scheme.lowercased() == "fido" else {
            return nil
        }
        
        guard context.featureFlagService.isEnabled(.liquidAuthEnabled) else {
            return .error(
                error: .liquidAuthError("Liquid Auth feature is not enabled"),
                resetHandler: nil
            )
        }
        
        return .liquidAuth(url: url)
    }
}
