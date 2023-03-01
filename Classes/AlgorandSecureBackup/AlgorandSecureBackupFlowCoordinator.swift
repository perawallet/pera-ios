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

    private let session: Session
    private unowned let presentingScreen: UIViewController

    init(session: Session, presentingScreen: UIViewController) {
        self.session = session
        self.presentingScreen = presentingScreen
    }
}

extension AlgorandSecureBackupFlowCoordinator {
    func launch() {
        openInstructions()
    }

    private func openInstructions() {
        let screen: Screen = .algorandSecureBackupInstructions { [weak self] event, screen in
            guard let self else { return }
            self.openPasswordScreenIfNeeded(from: screen)
        }
        presentingScreen.open(screen, by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil))
    }

    @discardableResult
    private func openAccountSelection(from viewController: UIViewController) -> UIViewController? {
        let screen: Screen = .algorandSecureBackupAccountList { [weak self] event, screen  in
            guard let self else { return }
            switch event {
            case .performContinue(let accounts):
                print(accounts)
            }
        }
        return viewController.open(screen, by: .push)
    }

    private func openPasswordScreenIfNeeded(from viewController: UIViewController) {
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
        guard viewControllers.last == choosePasswordViewController else { return }

        viewControllers.removeLast()

        guard let lastViewController = viewControllers.last else { return }
        guard let nextViewController = openAccountSelection(from: lastViewController) else { return }

        navigationController.setViewControllers(viewControllers + [nextViewController], animated: true)
    }
}

extension AlgorandSecureBackupFlowCoordinator {
    enum Event {
        case didFinish
    }
}
