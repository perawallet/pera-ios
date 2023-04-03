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

//   AlgorandSecureBackupFlowCoordinator.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils

final class AlgorandSecureBackupFlowCoordinator {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private var transition: Screen.Transition.Open?
    private let configuration: ViewControllerConfiguration
    private let presentingScreen: UIViewController

    init(configuration: ViewControllerConfiguration, presentingScreen: UIViewController) {
        self.configuration = configuration
        self.presentingScreen = presentingScreen
    }
}

extension AlgorandSecureBackupFlowCoordinator {
    func launch() {
        openInstructions(by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil))
    }

    func launchByPush() {
        openInstructions(by: .push)
    }

    private func openInstructions(by transition: Screen.Transition.Open) {
        let screen: Screen = .algorandSecureBackupInstructions { [weak self] event, screen in
            guard let self else { return }
            self.openPasswordScreenIfNeeded(from: screen)
        }
        presentingScreen.open(screen, by: transition)
        self.transition = transition
    }

    private func openPasswordScreenIfNeeded(from viewController: UIViewController) {
        guard let session = configuration.session else { return }

        guard session.hasPassword() else {
            openAccountSelection(from: viewController)
            return
        }

        let controller = viewController.open(
            .choosePassword(
                mode: .login(flow: .feature),
                flow: nil
            ),
            by: .push
        ) as? ChoosePasswordViewController
        controller?.delegate = self
    }

    private func makeAccountSelection() -> Screen {
        .algorandSecureBackupAccountList { [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .performContinue(let accounts):
                self.openMnemonicsScreen(with: accounts, from: screen)
            }
        }
    }

    private func openAccountSelection(from viewController: UIViewController) {
        viewController.open(makeAccountSelection(), by: .push)
    }

    private func openMnemonicsScreen(with accounts: [Account], from viewController: UIViewController) {
        let screen: Screen = .algorandSecureBackupMnemonic(accounts: accounts) { [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .backupCompleted(let encryptedBackupData):
                self.saveBackedUpAccounts(accounts)
                self.openSuccessScreen(with: encryptedBackupData, from: screen)
            case .backupFailed:
                self.openErrorScreen(from: screen)
            }
        }
        viewController.open(screen, by: .push)
    }

    private func openSuccessScreen(with data: Data, from viewController: UIViewController) {
        let secureBackup = AlgorandSecureBackup(data: data)
        let successScreen: Screen = .algorandSecureBackupSuccess(backup: secureBackup) { event, screen in
            switch event {
            case .complete:
                self.dismissScreen(from: screen)
            }
        }
        viewController.open(successScreen, by: .root)
    }

    private func openErrorScreen(from viewController: UIViewController) {
        let errorScreen: Screen = .algorandSecureBackupError { event, screen in
            switch event {
            case .performTryAgain:
                screen.popScreen()
            }
        }
        viewController.open(errorScreen, by: .set)
    }

    private func dismissScreen(from: UIViewController) {
        if transition == .push {
            from.navigationController?.setViewControllers([presentingScreen], animated: true)
        } else {
            from.dismissScreen()
        }
    }
}

extension AlgorandSecureBackupFlowCoordinator: ChoosePasswordViewControllerDelegate {
    func choosePasswordViewController(
        _ choosePasswordViewController: ChoosePasswordViewController,
        didConfirmPassword isConfirmed: Bool
    ) {
        guard isConfirmed else { return }

        choosePasswordViewController.open(makeAccountSelection(), by: .set)
    }
}

// MARK: Helpers
extension AlgorandSecureBackupFlowCoordinator {
    private func saveBackedUpAccounts(_ accounts: [Account]) {
        for account in accounts {
            let address = account.address
            let metadata = BackupMetadata(id: address, createdAtDate: Date())
            self.configuration.session?.backups[address] = metadata
        }
    }
}

extension AlgorandSecureBackupFlowCoordinator {
    enum Event {
        case didFinish
    }
}
