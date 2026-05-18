// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   JointAccountPendingTransactionOverlayConstructor.swift

//import UIKit
//import pera_wallet_core

enum JointAccountPendingTransactionOverlayConstructor {
    
    @MainActor
    static func buildScene(signRequestMetadata: SignRequestMetadata, isCancelTransactionAvailable: Bool, isSignWithLedgerActionAvailable: Bool, legacyBannerController: BannerController?) -> JointAccountPendingTransactionOverlay {
        let model = JointAccountPendingTransactionOverlayModel(
            signRequestMetadata: signRequestMetadata,
            isCancelTransactionAvailable: isCancelTransactionAvailable,
            isSignWithLedgerActionAvailable: isSignWithLedgerActionAvailable,
            accountsService: PeraCoreManager.shared.accounts,
            legacyBannerController: legacyBannerController
        )
        return JointAccountPendingTransactionOverlay(model: model)
    }
    
    @MainActor
    static func buildViewController(signRequestMetadata: SignRequestMetadata, isCancelTransactionAvailable: Bool,
                                    isSignWithLedgerActionAvailable: Bool, legacyConfiguration: ViewControllerConfiguration) -> JointAccountPendingTransactionOverlayViewController {
        let view = buildScene(
            signRequestMetadata: signRequestMetadata,
            isCancelTransactionAvailable: isCancelTransactionAvailable,
            isSignWithLedgerActionAvailable: isSignWithLedgerActionAvailable,
            legacyBannerController: AppDelegate.shared?.appConfiguration.bannerController
        )
        return JointAccountPendingTransactionOverlayViewController(configuration: legacyConfiguration, rootView: view)
    }
}
