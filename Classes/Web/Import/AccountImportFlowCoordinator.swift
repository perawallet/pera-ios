// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AccountImportFlowCoordinator.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils


final class AccountImportFlowCoordinator {
    private unowned let presentingScreen: UIViewController
    private var session: Session?

    init(
        presentingScreen: UIViewController,
        session: Session?
    ) {
        self.presentingScreen = presentingScreen
        self.session = session
    }
}

extension AccountImportFlowCoordinator {
    func launch(qrBackupParameters: QRBackupParameters?) {
        guard let qrBackupParameters else {
            openIntroductionScreen()
            return
        }

        openBackupScreen(with: qrBackupParameters, on: presentingScreen)
    }

    private func openIntroductionScreen() {
        let introductionScreen = Screen.importAccountIntroduction { [weak self] event, introductionScreen in
            guard let self else {
                return
            }

            switch event {
            case .didStart:
                self.openQRScannerScreen(on: introductionScreen)
            }
        }
        presentingScreen.open(introductionScreen, by: .push)
    }

    private func openBackupScreen(with parameters: QRBackupParameters, on screen: UIViewController) {
        let backupScreen = Screen.importAccountFetchBackup(parameters) { [weak self] event, backupScreen in
            guard let self else {
                return
            }

            switch event {
            case let .didSaveAccounts(importedAccounts, unimportedAccountsCount):
                break
            case .didFailToFetchBackup(let error):
                // route to error screen
                break
            }
        }

        screen.open(backupScreen, by: .push)
    }

    private func openQRScannerScreen(on screen: UIViewController) {
        let qrScannerScreen = Screen.importAccountQRScanner { [weak self] event, qrScannerScreen in
            guard let self else {
                return
            }

            switch event {
            case .didReadBackup(let parameters):
                self.openBackupScreen(with: parameters, on: qrScannerScreen)
            case .didReadUnsupportedAction(let parameters):
                print(parameters)
                self.openErrorScreen(on: qrScannerScreen)
            }
        }
        screen.open(qrScannerScreen, by: .push)
    }

    private func openErrorScreen(on screen: UIViewController) {
        let errorScreen = Screen.importAccountError { [weak self] event, _ in
            guard let self else {
                return
            }

            self.presentingScreen.dismissScreen()
        }

        screen.open(errorScreen, by: .push)
    }
}
