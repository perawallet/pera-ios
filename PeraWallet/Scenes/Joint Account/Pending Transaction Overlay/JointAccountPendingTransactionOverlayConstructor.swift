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

import Foundation

enum JointAccountPendingTransactionOverlayConstructor {
    
    static func buildScene(legacyBannerController: BannerController?, signRequestID: String, proposerAddress: String, signaturesInfo: [SignRequestInfo], threshold: Int, deadline: Date) -> JointAccountPendingTransactionOverlay {
        let model = JointAccountPendingTransactionOverlayModel(
            accountsService: PeraCoreManager.shared.accounts,
            legacyBannerController: legacyBannerController,
            signRequestID: signRequestID,
            proposerAddress: proposerAddress,
            signaturesInfo: signaturesInfo,
            threshold: threshold,
            deadline: deadline
        )
        return JointAccountPendingTransactionOverlay(model: model)
    }
    
    static func buildViewController(signRequestID: String, proposerAddress: String, signaturesInfo: [SignRequestInfo], threshold: Int, deadline: Date, onDismiss: (() -> Void)? = nil) -> JointAccountPendingTransactionOverlayViewController {
        let view = buildScene(
            legacyBannerController: AppDelegate.shared?.appConfiguration.bannerController,
            signRequestID: signRequestID,
            proposerAddress: proposerAddress,
            signaturesInfo: signaturesInfo,
            threshold: threshold,
            deadline: deadline
        )
        return JointAccountPendingTransactionOverlayViewController(rootView: view, onDismiss: onDismiss)
    }
    
    static func buildViewController(signRequestMetadata: SignRequestMetadata, onDismiss: (() -> Void)? = nil) -> JointAccountPendingTransactionOverlayViewController {
        let view = buildScene(
            legacyBannerController: AppDelegate.shared?.appConfiguration.bannerController,
            signRequestID: signRequestMetadata.signRequestID,
            proposerAddress: signRequestMetadata.proposerAddress,
            signaturesInfo: signRequestMetadata.signaturesInfo,
            threshold: signRequestMetadata.threshold,
            deadline: signRequestMetadata.deadline
        )
        return JointAccountPendingTransactionOverlayViewController(rootView: view, onDismiss: onDismiss)
    }
}
