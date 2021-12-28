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
//   AccountDetailViewController.swift

import Foundation
import UIKit

final class AccountDetailViewController: PageContainer {

    private lazy var assetListScreen = AccountAssetListViewController(configuration: configuration)
    private lazy var nftListScreen = AccountNFTListViewController(configuration: configuration)
    private lazy var transactionListScreen = AccountTransactionListViewController(configuration: configuration)

    private lazy var accountTitleView = AccountNameView()

    private let account: Account

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPageBarItems()
        addTitleView()
    }
}

extension AccountDetailViewController {
    private func setPageBarItems() {
        items = [
            AssetListPageBarItem(screen: assetListScreen),
            NFTListPageBarItem(screen: nftListScreen),
            TransactionListPageBarItem(screen: transactionListScreen)
        ]
    }

    private func addTitleView() {
        accountTitleView.customize(AccountNameViewSmallTheme())
        accountTitleView.bindData(AccountNameViewModel(account: account))

        navigationItem.titleView = accountTitleView
    }
}

extension AccountDetailViewController {
    struct AssetListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.assets.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-assets".localized)
            self.screen = screen
        }
    }

    struct NFTListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.nfts.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-ntfs".localized)
            self.screen = screen
        }
    }

    struct TransactionListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.transactions.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-history".localized)
            self.screen = screen
        }
    }


    enum AccountDetailPageBarItemID: String {
        case assets
        case nfts
        case transactions
    }
}
