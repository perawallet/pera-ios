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
//  AccountDetailViewController.swift

import UIKit

class AssetDetailViewController: BaseViewController {
    override var name: AnalyticsScreenName? {
        return .assetDetail
    }
    
    private var account: Account
    private var assetDetail: AssetDetail?
    var route: Screen?

//    private lazy var transactionActionsView = TransactionActionsView() <todo>: This will be floating action button

    private lazy var transactionsViewController = TransactionsViewController(
        provider: AssetDetailConfiguration(assetDetail: assetDetail, account: account),
        configuration: configuration
    )
    
    init(account: Account, configuration: ViewControllerConfiguration, assetDetail: AssetDetail? = nil) {
        self.account = account
        self.assetDetail = assetDetail
        super.init(configuration: configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log(DisplayAssetDetailEvent(assetId: assetDetail?.id))
    }
    
    override func linkInteractors() {
//        transactionActionsView.delegate = self
    }
    
    override func prepareLayout() {
        setupTransactionsViewController()
    }
}

extension AssetDetailViewController {
    private func setupTransactionsViewController() {
        addChild(transactionsViewController)
        view.addSubview(transactionsViewController.view)

        transactionsViewController.view.snp.makeConstraints {
            $0.leading.top.bottom.trailing.equalToSuperview()
        }

        transactionsViewController.didMove(toParent: self)
    }
}

//extension AssetDetailViewController: TransactionActionsViewDelegate { <todo>: This will be floating action button's delegate
//    func transactionActionsViewDidSendTransaction(_ transactionActionsView: TransactionActionsView) {
//        log(SendAssetDetailEvent(address: account.address))
//        if let assetDetail = assetDetail {
//            open(
//                .sendAssetTransactionPreview(
//                    account: account,
//                    receiver: .initial,
//                    assetDetail: assetDetail,
//                    isSenderEditable: false,
//                    isMaxTransaction: false
//                ),
//                by: .push
//            )
//        } else {
//            open(.sendAlgosTransactionPreview(account: account, receiver: .initial, isSenderEditable: false), by: .push)
//        }
//    }
//
//    func transactionActionsViewDidRequestTransaction(_ transactionActionsView: TransactionActionsView) {
//        log(ReceiveAssetDetailEvent(address: account.address))
//        let draft = QRCreationDraft(address: account.address, mode: .address, title: account.name)
//        open(.qrGenerator(title: account.name ?? account.address.shortAddressDisplay(), draft: draft, isTrackable: true), by: .present)
//    }
//}
