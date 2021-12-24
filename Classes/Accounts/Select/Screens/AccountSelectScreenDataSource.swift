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
//   AccountSelectScreenDataSource.swift


import Foundation
import UIKit

final class AccountSelectScreenDataSource: NSObject {
    weak var delegate: AccountSelectScreenDataSourceDelegate?

    private var accounts = [Account]()
    private var contacts = [Contact]()
    private(set) var list = [[AnyObject]]()

    var isEmpty: Bool {
        return accounts.isEmpty && contacts.isEmpty
    }

    /// It refers list's status, when keyword is searched
    var isListEmtpy: Bool {
        (list[safe: 0]?.isEmpty ?? false) && (list[safe: 1]?.isEmpty ?? false)
    }

    init(session: Session?) {
        super.init()

        accounts = session?.accounts ?? []
    }

    func loadData() {
        fetchContacts()
    }

    private func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }

                self.contacts.append(contentsOf: results)
            default:
                break
            }

            self.reloadData()
        }
    }

    private func reloadData() {
        self.list = [accounts, contacts]
        delegate?.accountSelectScreenDataSourceDidLoad(self)
    }

    func search(keyword: String?) {

        guard let searchKeyword = keyword else {
            reloadData()
            return
        }

        let filteredAccounts = accounts.filter { account in
            (account.name?.containsCaseInsensitive(searchKeyword) ?? false) ||
            (account.address.containsCaseInsensitive(searchKeyword))
        }

        let filteredContacts = contacts.filter { contact in
            (contact.name?.containsCaseInsensitive(searchKeyword) ?? false) ||
            (contact.address?.containsCaseInsensitive(searchKeyword) ?? false)
        }

        self.list = [filteredAccounts, filteredContacts]
    }

    func item(at indexPath: IndexPath) -> AnyObject? {
        guard let safeArray = list[safe: indexPath.section] else {
            return nil
        }

        return safeArray[safe: indexPath.item]
    }
}

extension AccountSelectScreenDataSource:
UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list[safe: section]?.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        // First section shows Accounts
        if indexPath.section == 0 {
            let cell = collectionView.dequeue(AccountPreviewCell.self, at: indexPath)
            cell.customize(AccountPreviewViewTheme())

            if let account = accounts[safe: indexPath.item] {
                cell.bindData(
                    AccountNameViewModel(account: account, hasImage: true)
                )
            }

            return cell
        } else {
            let cell = collectionView.dequeue(SelectContactCell.self, at: indexPath)
            let theme = SelectContactViewTheme()
            cell.customize(theme)

            if let contact = contacts[safe: indexPath.item] {
                cell.bindData(
                    ContactsViewModel(
                        contact: contact,
                        imageSize: CGSize(width: theme.imageSize.w, height: theme.imageSize.h)
                    )
                )
            }

            return cell
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return list.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        let headerView = collectionView.dequeueHeader(
            SelectAccountHeaderSupplementaryView.self,
            at: indexPath
        )

        headerView.configureAppearance()

        if indexPath.section == 0 {
            headerView.bind(SelectAccountHeaderViewModel(.accounts))
        } else {
            headerView.bind(SelectAccountHeaderViewModel(.contacts))
        }

        return headerView
    }

}

protocol AccountSelectScreenDataSourceDelegate: AnyObject {
    func accountSelectScreenDataSourceDidLoad(_ dataSource: AccountSelectScreenDataSource)
}
