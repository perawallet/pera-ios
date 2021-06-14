// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   WCConnectionApprovalViewController.swift

import UIKit

class WCConnectionApprovalViewController: BaseViewController {

    private lazy var connectionApprovalView = WCConnectionApprovalView()

    private let walletConnectSession: WalletConnectSession
    private let walletConnectSessionConnectionCompletionHandler: WalletConnectSessionConnectionCompletionHandler

    private var selectedAccount: Account?

    init(
        walletConnectSession: WalletConnectSession,
        walletConnectSessionConnectionCompletionHandler: @escaping WalletConnectSessionConnectionCompletionHandler,
        configuration: ViewControllerConfiguration
    ) {
        self.walletConnectSession = walletConnectSession
        self.walletConnectSessionConnectionCompletionHandler = walletConnectSessionConnectionCompletionHandler
        super.init(configuration: configuration)
        selectedAccount = session?.accounts.first
    }

    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary

        if let account = selectedAccount {
            connectionApprovalView.bind(WCConnectionApprovalViewModel(session: walletConnectSession, account: account))
        }
    }

    override func prepareLayout() {
        super.prepareLayout()
        prepareWholeScreenLayoutFor(connectionApprovalView)
    }

    override func linkInteractors() {
        super.linkInteractors()
        connectionApprovalView.delegate = self
    }
}

extension WCConnectionApprovalViewController {

}

extension WCConnectionApprovalViewController: WCConnectionApprovalViewDelegate {
    func wcConnectionApprovalViewDidApproveConnection(_ wcConnectionApprovalView: WCConnectionApprovalView) {
        guard let account = selectedAccount else {
            return
        }

        walletConnectSessionConnectionCompletionHandler(walletConnectSession.getApprovedWalletConnectionInfo(for: account.address))
        dismissScreen()
    }

    func wcConnectionApprovalViewDidRejectConnection(_ wcConnectionApprovalView: WCConnectionApprovalView) {
        walletConnectSessionConnectionCompletionHandler(walletConnectSession.getDeclinedWalletConnectionInfo())
        dismissScreen()
    }

    func wcConnectionApprovalViewDidSelectAccountSelection(_ wcConnectionApprovalView: WCConnectionApprovalView) {
        let accountListViewController = open(.accountList(mode: .empty), by: .present) as? AccountListViewController
        accountListViewController?.delegate = self
    }
}

extension WCConnectionApprovalViewController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        selectedAccount = account
        connectionApprovalView.bind(WCConnectionAccountSelectionViewModel(account: account))
    }
}
