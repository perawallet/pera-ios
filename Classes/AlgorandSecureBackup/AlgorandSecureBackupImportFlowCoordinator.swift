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

//   AlgorandSecureBackupImportFlowCoordinator.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils

final class AlgorandSecureBackupImportFlowCoordinator {
    private let configuration: ViewControllerConfiguration
    private unowned let presentingScreen: UIViewController

    init(configuration: ViewControllerConfiguration, presentingScreen: UIViewController) {
        self.configuration = configuration
        self.presentingScreen = presentingScreen
    }
}

extension AlgorandSecureBackupImportFlowCoordinator {
    func launch() {
        openImportBackup()
    }

    private func openImportBackup() {
        let screen: Screen = .algorandSecureBackupImportBackup { [weak self] event, screen in
            guard let self else { return }
            switch event {
            case .backupImported(let backupData):
                self.openImportMnemonic(with: backupData, from: screen)
            }
        }
        presentingScreen.open(screen, by: .push)
    }
}

extension AlgorandSecureBackupImportFlowCoordinator {
    private func openImportMnemonic(with data: Data, from viewController: UIViewController) {
        print(data)
    }

    private func openSuccessScreen(
        with configuration: ImportAccountScreen.Configuration,
        from viewController: UIViewController
    ) {
        let screen: Screen = .algorandSecureBackupImportSuccess(configuration: configuration) { event, screen in
            switch event {
            case .didGoToHome:
                screen.dismissScreen()
            }
        }

        viewController.open(screen, by: .push)
    }
}

