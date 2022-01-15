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
//   WCMainTransactionScreen.swift

import Foundation
import MacaroonUIKit
import MacaroonBottomOverlay
import UIKit
import SnapKit

final class WCMainTransactionScreen: BaseViewController, Container {
    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var dappMessageView = WCTransactionDappMessageView()

    private lazy var theme = Theme()

    private lazy var singleTransactionFragment: WCSingleTransactionRequestScreen = {
        let dataSource = WCMainTransactionDataSource(
            transactions: transactions,
            transactionRequest: transactionRequest,
            transactionOption: transactionOption,
            session: self.session,
            walletConnector: self.walletConnector
        )

        return WCSingleTransactionRequestScreen(
            dataSource: dataSource,
            configuration: configuration
        )
    }()

    let transactions: [WCTransaction]
    let transactionRequest: WalletConnectRequest
    let transactionOption: WCTransactionOption?

    init(
        transactions: [WCTransaction],
        transactionRequest: WalletConnectRequest,
        transactionOption: WCTransactionOption?,
        configuration: ViewControllerConfiguration
    ) {
        self.transactions = transactions
        self.transactionRequest = transactionRequest
        self.transactionOption = transactionOption
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = theme.backgroundColor
    }

    override func prepareLayout() {
        super.prepareLayout()

        addDappInfoView()
        addSingleTransaction()
    }

    override func linkInteractors() {
        super.linkInteractors()

    }

    override func bindData() {
        super.bindData()

        guard let wcSession = walletConnector.allWalletConnectSessions.first(matching: (\.urlMeta.wcURL, transactionRequest.url)) else {
            return
        }

        let viewModel = WCTransactionDappMessageViewModel(
            session: wcSession,
            imageSize: CGSize(width: 48.0, height: 48.0)
        )

        dappMessageView.bind(viewModel)
    }

    private func addDappInfoView() {
        view.addSubview(dappMessageView)
        dappMessageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(theme.dappViewLeadingInset)
            make.top.safeEqualToTop(of: self).offset(theme.dappViewTopInset)
        }
    }

    private func addSingleTransaction() {
        addFragment(NavigationController(rootViewController: singleTransactionFragment)) { fragmentView in
            fragmentView.roundCorners(corners: [.topLeft, .topRight], radius: theme.fragmentRadius)
            view.addSubview(fragmentView)
            fragmentView.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(theme.fragmentTopInset)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
}
