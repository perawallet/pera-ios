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
//   OrderAccountListViewController.swift

import MacaroonUIKit
import MacaroonUtils
import UIKit

final class OrderAccountListViewController: BaseViewController {
    private lazy var theme = Theme()
    private lazy var listView = UITableView()
    private let accountType: AccountType
    private var accounts: [Account] = []

    init(accountType: AccountType, configuration: ViewControllerConfiguration) {
        self.accountType = accountType
        super.init(configuration: configuration)

        switch accountType {
        case .watch:
            accounts = session!.accounts.filter { $0.isWatchAccount() }
        default:
            accounts = session!.accounts.filter { !$0.isWatchAccount() }
        }
    }

    override func configureNavigationBarAppearance() {
        setBarButtons()
    }

    override func configureAppearance() {
        title = "account-options-arrange-list-title".localized
    }

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
    }

    override func setListeners() {
        super.setListeners()
        listView.dataSource = self
        listView.delegate = self
    }
}

extension OrderAccountListViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }

        listView.register(AccountPreviewTableCell.self, forCellReuseIdentifier: AccountPreviewTableCell.reuseIdentifier)
        listView.rowHeight = UITableView.automaticDimension
        listView.estimatedRowHeight = theme.itemHeight
        listView.separatorStyle = .none
        listView.separatorInset = .zero
        listView.verticalScrollIndicatorInsets.top = .leastNonzeroMagnitude
        listView.dragInteractionEnabled = true
        listView.isEditing = true
    }

    private func setBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done) { [weak self] in
            guard let self = self else {
                return
            }

            self.dismissScreen()
        }

        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            guard let self = self else {
                return
            }

            self.dismissScreen()
        }

        leftBarButtonItems = [closeBarButtonItem]
        rightBarButtonItems = [doneBarButtonItem]
    }
}

extension OrderAccountListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(
        _ tableView: UITableView,
        shouldIndentWhileEditingRowAt indexPath: IndexPath
    ) -> Bool {
        return false
    }
}

extension OrderAccountListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return accounts.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AccountPreviewTableCell.reuseIdentifier,
            for: indexPath
        ) as? AccountPreviewTableCell else {
            crash("Cell not supported of \(type(of: SingleLineIconTitleCell.self))")
        }

        let account = accounts[indexPath.item]
        let accountNameViewModel = AccountNameViewModel(account: account)
        cell.bindData(AccountPreviewViewModel(viewModel: accountNameViewModel))
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        let movedObject = accounts[sourceIndexPath.row]
        accounts.remove(at: sourceIndexPath.row)
        accounts.insert(movedObject, at: destinationIndexPath.row)
    }
}
