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

    private lazy var transactionActionsView = TransactionActionsView()
    
    private lazy var assetDetailTitleView = AssetDetailTitleView(title: account.name)
    
    private lazy var assetCardDisplayViewController: AssetCardDisplayViewController = {
        var selectedIndex = 0
        if let assetDetail = assetDetail {
            selectedIndex = (account.assetDetails.firstIndex(of: assetDetail) ?? 0) + 1
        }
        
        return AssetCardDisplayViewController(account: account, selectedIndex: selectedIndex, configuration: configuration)
    }()
    
    private lazy var transactionsViewController = TransactionsViewController(
        account: account,
        configuration: configuration,
        assetDetail: assetDetail
    )
    
    init(account: Account, configuration: ViewControllerConfiguration, assetDetail: AssetDetail? = nil) {
        self.account = account
        self.assetDetail = assetDetail
        super.init(configuration: configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleDeepLinkRoutingIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log(DisplayAssetDetailEvent(assetId: assetDetail?.id))
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        navigationItem.titleView = assetDetailTitleView
        assetDetailTitleView.bind(AssetDetailTitleViewModel(account: account, assetDetail: assetDetail))
    }
    
    override func linkInteractors() {
        transactionActionsView.delegate = self
        assetCardDisplayViewController.delegate = self
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAccountUpdate(notification:)),
            name: .AccountUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAccountUpdate(notification:)),
            name: .AuthenticatedUserUpdate,
            object: nil
        )
    }
    
    override func prepareLayout() {
        setupAssetCardDisplayViewController()
        if !account.isWatchAccount() {
            setupTransactionActionsViewLayout()
        }
        setupTransactionsViewController()
    }
}

extension AssetDetailViewController {
    private func setupAssetCardDisplayViewController() {
        addChild(assetCardDisplayViewController)
        view.addSubview(assetCardDisplayViewController.view)

        assetCardDisplayViewController.view.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(AssetCardDisplayView.CardViewConstants.height)
        }
        
        assetCardDisplayViewController.didMove(toParent: self)
    }
    
    private func setupTransactionActionsViewLayout() {
        view.addSubview(transactionActionsView)
        
        transactionActionsView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaBottom + 92.0)
        }
    }
    
    private func setupTransactionsViewController() {
        addChild(transactionsViewController)
        view.addSubview(transactionsViewController.view)

        transactionsViewController.view.snp.makeConstraints { make in make.top.equalTo(assetCardDisplayViewController.view.snp.bottom).offset(0.0)
            make.leading.trailing.equalToSuperview()
            
            if account.isWatchAccount() {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.equalTo(transactionActionsView.snp.top)
            }
        }

        transactionsViewController.didMove(toParent: self)
    }
}

extension AssetDetailViewController {
    private func handleDeepLinkRoutingIfNeeded() {
        if let route = route {
            switch route {
            case .assetDetail:
                self.route = nil
                updateLayout()
            default:
                self.route = nil
                open(route, by: .push, animated: false)
            }
        }
    }
    
    private func updateLayout() {
        guard let account = session?.account(from: account.address) else {
            return
        }
        
        assetCardDisplayViewController.updateAccount(account)
        transactionsViewController.updateList()
    }
}

extension AssetDetailViewController {
    @objc
    private func didAccountUpdate(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Account],
            let updatedAccount = userInfo["account"] else {
            return
        }
        
        if account == updatedAccount {
            account = updatedAccount
            updateLayout()
        }
    }
}

extension AssetDetailViewController: TransactionActionsViewDelegate {
    func transactionActionsViewDidSendTransaction(_ transactionActionsView: TransactionActionsView) {
        log(SendAssetDetailEvent(address: account.address))
        if let assetDetail = assetDetail {
            open(
                .sendAssetTransactionPreview(
                    account: account,
                    receiver: .initial,
                    assetDetail: assetDetail,
                    isSenderEditable: false,
                    isMaxTransaction: false
                ),
                by: .push
            )
        } else {
            open(.sendAlgosTransactionPreview(account: account, receiver: .initial, isSenderEditable: false), by: .push)
        }
    }
    
    func transactionActionsViewDidRequestTransaction(_ transactionActionsView: TransactionActionsView) {
        log(ReceiveAssetDetailEvent(address: account.address))
        let draft = QRCreationDraft(address: account.address, mode: .address, title: account.name)
        open(.qrGenerator(title: account.name ?? account.address.shortAddressDisplay(), draft: draft, isTrackable: true), by: .present)
    }
}

extension AssetDetailViewController: AssetCardDisplayViewControllerDelegate {
    func assetCardDisplayViewController(_ assetCardDisplayViewController: AssetCardDisplayViewController, didSelect index: Int) {
        assetDetail = index == 0 ? nil : account.assetDetails[safe: index - 1]
        log(ChangeAssetDetailEvent(assetId: assetDetail?.id))
        assetDetailTitleView.bind(AssetDetailTitleViewModel(account: account, assetDetail: assetDetail))
        transactionsViewController.updateSelectedAsset(assetDetail)
    }
}
