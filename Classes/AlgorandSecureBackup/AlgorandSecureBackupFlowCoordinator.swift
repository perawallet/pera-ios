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

//   AlgorandSecureBackupFlowCoordinator.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils

final class AlgorandSecureBackupFlowCoordinator {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private var launchTransition: Screen.Transition.Open?
    private let configuration: ViewControllerConfiguration
    private let presentingScreen: UIViewController

    init(configuration: ViewControllerConfiguration, presentingScreen: UIViewController) {
        self.configuration = configuration
        self.presentingScreen = presentingScreen
    }
}

extension AlgorandSecureBackupFlowCoordinator {
    func launch(
        by transition: Screen.Transition.Open =
            .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
    ) {
        openInstructions(by: transition)
    }

    private func openInstructions(by transition: Screen.Transition.Open) {
        presentingScreen.open(makeInstructionScreen(), by: transition)
        self.launchTransition = transition
    }

    private func makeInstructionScreen() -> Screen {
        .algorandSecureBackupInstructions { [weak self] event, screen in
            guard let self else { return }
            switch event {
            case .performStartASB:
                self.openPasswordScreenIfNeeded(from: screen)
            }
            
        }
    }

    private func openPasswordScreenIfNeeded(from viewController: UIViewController) {
        guard let session = configuration.session else { return }

        guard session.hasPassword() else {
            openMnemonicsScreen(from: viewController)
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

    private func openMnemonicsScreen(from viewController: UIViewController) {
        let screen = createASBMnmonicScreen()
        viewController.open(screen, by: .push)
    }
    
    private func createASBMnmonicScreen() -> Screen {
        let accounts = configuration.session?.authenticatedUser?.accounts
            .filter { $0.hdWalletAddressDetail == nil && $0.ledgerDetail == nil}
            .map { Account(localAccount: $0)} ?? []
        return .algorandSecureBackupMnemonic(accounts: accounts) { [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .backupCompleted(let encryptedBackupData):
                self.saveBackupMetadata(for: accounts)
                self.openSuccessScreen(with: encryptedBackupData, from: screen)
            case .backupFailed:
                self.openErrorScreen(from: screen)
            }
        }
    }

    private func openSuccessScreen(with data: Data, from viewController: UIViewController) {
        let secureBackup = AlgorandSecureBackup(data: data)
        let successScreen: Screen = .algorandSecureBackupSuccess(backup: secureBackup) { event, screen in
            switch event {
            case .complete:
                self.dismissScreen(from: screen)
            }
        }
        viewController.open(successScreen, by: .push)
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
        if launchTransition == .push {
            guard let navController = from.navigationController else {
                from.dismissScreen()
                return
            }
            if let settingsVC = navController.viewControllers.first(where: { $0 === presentingScreen }) {
                navController.popToViewController(settingsVC, animated: true)
            } else {
                navController.setViewControllers([presentingScreen], animated: true)
            }
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

        guard let navigationController = choosePasswordViewController.navigationController else {
            return
        }

        var viewControllers = navigationController.viewControllers

        for (index, viewController) in viewControllers.enumerated() {
            if viewController is ChoosePasswordViewController {
                let asbMnmonicScreen = viewController.open(
                    createASBMnmonicScreen(),
                    by: .push
                ) as! AlgorandSecureBackupMnemonicsScreen
                viewControllers.append(asbMnmonicScreen)

                viewControllers.remove(at: index)
                break
            }
        }

        navigationController.setViewControllers(viewControllers, animated: false)
    }
}

// MARK: Helpers
extension AlgorandSecureBackupFlowCoordinator {
    private func saveBackupMetadata(for accounts: [Account]) {
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
