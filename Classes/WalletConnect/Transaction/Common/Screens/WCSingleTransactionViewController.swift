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
//   WCSingleTransactionViewController.swift

import UIKit
import MagpieCore

class WCSingleTransactionViewController: BaseScrollViewController {
    
    private let layout = Layout<LayoutConstants>()

    var transactionView: WCSingleTransactionView? {
        return nil
    }

    private lazy var dappMessageModalTransition = BottomSheetTransition(presentingViewController: self)

    private(set) var transaction: WCTransaction
    private(set) var account: Account?
    private(set) var transactionRequest: WalletConnectRequest
    private let wcSession: WCSession?

    init(transaction: WCTransaction, transactionRequest: WalletConnectRequest, configuration: ViewControllerConfiguration) {
        self.transaction = transaction
        self.account = configuration.session?.accounts.first(matching: (\.address, transaction.transactionDetail?.sender))
        self.transactionRequest = transactionRequest
        self.wcSession = configuration.walletConnector.getWalletConnectSession(with: WCURLMeta(wcURL: transactionRequest.url))
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        if let wcSession = wcSession {
            transactionView?.bind(WCSingleTransactionViewModel(wcSession: wcSession, transaction: transaction))
        }
    }

    override func linkInteractors() {
        super.linkInteractors()
        transactionView?.mainDelegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupTransactionViewLayout()
    }
}

extension WCSingleTransactionViewController {
    private func setupTransactionViewLayout() {
        guard let transactionView = transactionView else {
            return
        }

        contentView.addSubview(transactionView)

        transactionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension WCSingleTransactionViewController: WCSingleTransactionViewDelegate {
    func wcSingleTransactionViewDidOpenLongDappMessage(_ wcSingleTransactionView: WCSingleTransactionView) {
        openLongDappMessageScreen()
    }

    @objc
    private func openLongDappMessageScreen() {
        guard let wcSession = wcSession,
              let message = transaction.message else {
            return
        }
        dappMessageModalTransition.perform(
            .wcTransactionFullDappDetail(
                wcSession: wcSession,
                message: message
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension WCSingleTransactionViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 8.0
        let bottomInset: CGFloat = 40.0
    }
}
