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
//   WCAssetTransactionViewController.swift

import UIKit

class WCAssetTransactionViewController: WCTransactionViewController {

    private lazy var assetTransactionView = WCAssetTransactionView()

    override var transactionView: WCSingleTransactionView? {
        return assetTransactionView
    }

    private var assetDetail: AssetDetail?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let assetId = transactionParameter.transaction?.assetId else {
            return
        }

        cacheAssetDetail(with: assetId) { [weak self] assetDetail in
            guard let self = self else {
                return
            }

            if assetDetail == nil {
                self.walletConnector.rejectTransactionRequest(self.transactionRequest, with: .invalidInput)
                self.dismissScreen()
                return
            }

            self.assetDetail = assetDetail
            self.bindView()
        }
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "wallet-connect-transaction-title-asset".localized
        bindView()
    }

    private func bindView() {
        assetTransactionView.bind(
            WCAssetTransactionViewModel(
                transactionParams: transactionParameter,
                senderAccount: account,
                assetDetail: assetDetail)
        )
    }

    override func linkInteractors() {
        super.linkInteractors()
        assetTransactionView.delegate = self
    }
}

extension WCAssetTransactionViewController: WCAssetTransactionViewDelegate {
    func wcAssetTransactionViewDidOpenRawTransaction(_ wcAssetTransactionView: WCAssetTransactionView) {
        
    }
}

extension WCAssetTransactionViewController: AssetCachable { }
