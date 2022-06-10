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
    func launch() {
        presentingScreen.open(
            .accountSelection(transactionAction: .send, delegate: self),
            by: .present
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

        let screen: Screen = .assetSelection(
            filter: nil,
            account: account
        )

        selectAccountViewController.open(
            screen,
            by: .push
        )
    }
}
