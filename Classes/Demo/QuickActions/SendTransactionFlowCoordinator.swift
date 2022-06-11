// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SendTransactionCoordinator.swift

import Foundation
import UIKit

/// <todo>
/// This should be removed after the routing refactor.
final class SendTransactionFlowCoordinator: SelectAccountViewControllerDelegate {
    private unowned let presentingScreen: UIViewController

    init(
        presentingScreen: UIViewController
    ) {
        self.presentingScreen = presentingScreen
    }
}

extension SendTransactionFlowCoordinator {
    func launch(with account: Account? = nil) {
        guard let account = account else {
            openAccountSelection()
            return
        }

        openAssetSelection(with: account)
    }

    private func openAccountSelection() {
        presentingScreen.open(
            .accountSelection(transactionAction: .send, delegate: self),
            by: .present
        )
    }

    private func openAssetSelection(with account: Account, on screen: UIViewController? = nil) {
        let assetSelectionScreen: Screen = .assetSelection(
            filter: nil,
            account: account
        )

        guard let screen = screen else {
            presentingScreen.open(
                assetSelectionScreen,
                by: .present
            )
            return
        }

        screen.open(
            assetSelectionScreen,
            by: .root
        )
    }
}

/// <mark>
/// SelectAccountViewControllerDelegate
extension SendTransactionFlowCoordinator {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for transactionAction: TransactionAction
    ) {
        if transactionAction != .send {
            return
        }

        openAssetSelection(with: account, on: selectAccountViewController)
    }
}
