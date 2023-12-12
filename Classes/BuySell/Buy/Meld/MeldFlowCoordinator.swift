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

//   MeldFlowCoordinator.swift

import Foundation
import UIKit

final class MeldFlowCoordinator {
    private unowned let presentingScreen: UIViewController

    init(
        presentingScreen: UIViewController
    ) {
        self.presentingScreen = presentingScreen
    }
}

extension MeldFlowCoordinator {
    /// When an account is not passed to the function, the account selection flow is triggered within the overall flow.
    func launch(_ account: AccountHandle? = nil) {
        if let account {
            openDappDetail(
                with: account,
                from: presentingScreen,
                with: .present
            )
            return
        }

        openAccountSelection(from: presentingScreen)
    }
}

extension MeldFlowCoordinator {
    private func openAccountSelection(from screen: UIViewController) {
        let accountSelectionScreen = Screen.meldAccountSelection {
            [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .didSelect(let account):
                self.openDappDetail(
                    with: account,
                    from: screen,
                    with: .push
                )
            default: break
            }
        }

        screen.open(
            accountSelectionScreen,
            by: .present
        )
    }
}

extension MeldFlowCoordinator {
    private func openDappDetail(
        with account: AccountHandle,
        from screen: UIViewController,
        with transition: Screen.Transition.Open
    ) {
        let dAppDetail = screen.open(
            .meldDappDetail(account: account),
            by: transition
        ) as? DiscoverExternalInAppBrowserScreen
        dAppDetail?.eventHandler = {
            [weak dAppDetail] event in
            switch event {
            case .goBack:
                dAppDetail?.dismiss(animated: true)
            default: break
            }
        }
    }
}
