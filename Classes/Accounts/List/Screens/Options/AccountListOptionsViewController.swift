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
//   AccountListOptionsViewController.swift

import MacaroonUIKit
import UIKit
import MacaroonUtils
import MacaroonBottomSheet

final class AccountListOptionsViewController: BaseViewController {
    private lazy var theme = Theme()
    lazy var handlers = Handlers()
    private let accountType: AccountType

    private lazy var listView = UITableView()

    init(accountType: AccountType, configuration: ViewControllerConfiguration) {
        self.accountType = accountType
        super.init(configuration: configuration)
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

extension AccountListOptionsViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }

        listView.register(SingleLineIconTitleCell.self, forCellReuseIdentifier: SingleLineIconTitleCell.reuseIdentifier)
        listView.rowHeight = UITableView.automaticDimension
        listView.estimatedRowHeight = theme.itemHeight
        listView.separatorStyle = .none
        listView.separatorInset = .zero
        listView.verticalScrollIndicatorInsets.top = .leastNonzeroMagnitude
    }
}

extension AccountListOptionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountListOptions.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SingleLineIconTitleCell.reuseIdentifier,
            for: indexPath
        ) as? SingleLineIconTitleCell,
              let option = AccountListOptions(rawValue: indexPath.item) else {
            crash("Cell not supported of \(type(of: SingleLineIconTitleCell.self))")
        }

        cell.bindData(
            SingleLineIconTitleViewModel(
                item: SingleLineIconTitleItem(
                    icon: option.image,
                    title: option.title
                )
            )
        )

        return cell
    }
}

extension AccountListOptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let option = AccountListOptions(rawValue: indexPath.item) {
            dismissScreen()
            handlers.didSelect?(option, accountType)
        }
    }
}

extension AccountListOptionsViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .preferred(theme.modalHeight + view.safeAreaBottom)
    }
}

extension AccountListOptionsViewController {
    struct Handlers {
        var didSelect: ((AccountListOptions, AccountType) -> Void)?
    }
}

enum AccountListOptions: Int, CaseIterable {
    case add
    case arrange

    var image: Image {
        switch self {
        case .add:
            return "icon-plus-24"
        case .arrange:
            return "icon-arrange-24"
        }
    }

    var title: EditText {
        switch self {
        case .add:
            return .string("account-options-add-account-title".localized)
        case .arrange:
            return .string("account-options-arrange-list-title".localized)
        }
    }
}
