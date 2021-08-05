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
//   WCAppCallTransactionViewController.swift

import UIKit

class WCAppCallTransactionViewController: WCSingleTransactionViewController {

    private lazy var appCallTransactionView = WCAppCallTransactionView()

    override var transactionView: WCSingleTransactionView? {
        return appCallTransactionView
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "wallet-connect-transaction-title-app-call".localized
    }

    override func linkInteractors() {
        super.linkInteractors()
        appCallTransactionView.delegate = self
    }

    override func bindData() {
        appCallTransactionView.bind(WCAppCallTransactionViewModel(transaction: transaction, account: account))
    }
}

extension WCAppCallTransactionViewController: WCAppCallTransactionViewDelegate {
    func wcAppCallTransactionViewDidOpenRawTransaction(_ wcAppCallTransactionView: WCAppCallTransactionView) {
        displayRawTransaction()
    }
}

extension WCAppCallTransactionViewController: WCSingleTransactionViewControllerActionable { }
