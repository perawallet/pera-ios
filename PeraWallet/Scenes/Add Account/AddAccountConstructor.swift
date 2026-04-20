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

//   AddAccountConstructor.swift

import SwiftUI

enum AddAccountConstructor {
    
    static func buildScene(legacyConfiguration: ViewControllerConfiguration) -> AddAccountView {
        let model = AddAccountModel(legacyConfiguration: legacyConfiguration)
        return AddAccountView(model: model)
    }
    
    static func buildCompatibilityViewController(legacyConfiguration: ViewControllerConfiguration) -> BaseViewController {
        
        let model = AddAccountModel(legacyConfiguration: legacyConfiguration)
        let controller = AddAccountViewController(model: model)
        let compatibilityController = AddAccountCompatibilityController(configuration: legacyConfiguration, hostingController: controller)
        
        controller.onLegacyNavigationOptionSelected = { [weak compatibilityController] in
            compatibilityController?.moveTo(option: $0)
        }
        
        controller.onDismissRequest = { [weak compatibilityController] in
            compatibilityController?.dismiss()
        }
        
        controller.onLearnMoreTap = { [weak compatibilityController] in
            compatibilityController?.learnMore()
        }
        
        controller.onScanQRTap = { [weak compatibilityController, weak controller] in
            guard let compatibilityController, let controller else { return }
            compatibilityController.scanQR { address in
                controller.onAddressScanned(address: address)
            }
        }
        
        controller.onJointAccountAnalyticsCall = { event in
            switch event {
            case .welcomePressed:
                legacyConfiguration.analytics.track(.jointAccount(type: .welcomePressed))
            case .addAccount:
                legacyConfiguration.analytics.track(.jointAccount(type: .addAccount))
            case .editAccount:
                legacyConfiguration.analytics.track(.jointAccount(type: .editAccount))
            case .removeAddress:
                legacyConfiguration.analytics.track(.jointAccount(type: .removeAddress))
            case .addAccountContinue:
                legacyConfiguration.analytics.track(.jointAccount(type: .addAccountContinue))
            case .addAccountContinueFromInbox:
                legacyConfiguration.analytics.track(.jointAccount(type: .addAccountContinueFromInbox))
            case .thresholdContinue:
                legacyConfiguration.analytics.track(.jointAccount(type: .thresholdContinue))
            case .nameAccount:
                legacyConfiguration.analytics.track(.jointAccount(type: .nameAccount))
            case .infoScreenProceed:
                legacyConfiguration.analytics.track(.jointAccount(type: .infoScreenProceed))
            case .infoScreenGoBack:
                legacyConfiguration.analytics.track(.jointAccount(type: .infoScreenGoBack))
            case .cancelTransaction:
                legacyConfiguration.analytics.track(.jointAccount(type: .cancelTransaction))
            case .confirmTransaction:
                legacyConfiguration.analytics.track(.jointAccount(type: .confirmTransaction))
            case .declinePendingTransaction:
                legacyConfiguration.analytics.track(.jointAccount(type: .declinePendingTransaction))
            case .closeForNow:
                legacyConfiguration.analytics.track(.jointAccount(type: .closeForNow))
            case .closePendingTransaction:
                legacyConfiguration.analytics.track(.jointAccount(type: .closePendingTransaction))
            }
        }
        
        return compatibilityController
    }
}
