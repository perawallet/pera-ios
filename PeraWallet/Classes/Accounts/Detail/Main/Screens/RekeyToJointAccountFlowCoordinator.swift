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

//   RekeyToJointAccountFlowCoordinator.swift

import UIKit
import pera_wallet_core

final class RekeyToJointAccountFlowCoordinator {
    
    // MARK: - Properties
    
    private weak var presenter: UIViewController?
    private let sharedDataController: SharedDataController
    
    // MARK: - Initialisers
    
    init(presenter: UIViewController, sharedDataController: SharedDataController) {
        self.presenter = presenter
        self.sharedDataController = sharedDataController
    }
    
    // MARK: - Actions
    
    func launchFlow(sourceAccount: Account) {
        openInstructionsScreen(sourceAccount: sourceAccount)
    }
    
    private func openInstructionsScreen(sourceAccount: Account) {
        
        guard let screen = presenter?.open(.rekeyToJointAccountInstructions(sourceAccount: sourceAccount), by: .present) as? RekeyInstructionsScreen else { return }
        
        screen.eventHandler = { [weak self] in
            switch $0 {
            case .performPrimaryAction:
                self?.openSelectAccountScreen(sourceAccount: sourceAccount, presenter: screen)
            case .performCloseAction:
                self?.presenter?.dismiss(animated: true)
            }
        }
    }
    
    private func openSelectAccountScreen(sourceAccount: Account, presenter: UIViewController) {
        
        let eventHandler: AccountSelectionListScreen<RekeyAccountSelectionListLocalDataController>.EventHandler = { [weak self] event, screen in
            switch event {
            case let .didSelect(accountHandle):
                self?.openRekeyConfirmation(sourceAccount: sourceAccount, newAuthAccount: accountHandle.value, presenter: screen)
            case .didOptInToAsset:
                break
            }
        }
        
        presenter.open(.rekeyAccountSelection(eventHandler: eventHandler, account: sourceAccount), by: .push)
    }
    
    private func openRekeyConfirmation(sourceAccount: Account, newAuthAccount: Account, presenter: UIViewController) {
        let authAccount = sharedDataController.authAccount(of: sourceAccount)?.value
        presenter.open(.rekeyConfirmation(sourceAccount: sourceAccount, authAccount: authAccount, newAuthAccount: newAuthAccount), by: .push)
    }
}
