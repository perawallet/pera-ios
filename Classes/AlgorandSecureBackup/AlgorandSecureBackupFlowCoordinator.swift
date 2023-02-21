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

    private unowned let presentingScreen: UIViewController

    init(presentingScreen: UIViewController) {
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
            self.openAccountSelection(from: screen)
        }
        presentingScreen.open(screen, by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil))
    }

    private func openAccountSelection(from viewController: UIViewController) {
        let screen: Screen = .algorandSecureBackupAccountList { [weak self] event, screen  in
            guard let self else { return }
            switch event {
            case .performContinue(let accounts):
                print(accounts)
            }
        }
        viewController.open(screen, by: .push)
    }
}

extension AlgorandSecureBackupFlowCoordinator {
    enum Event {
        case didFinish
    }
}
