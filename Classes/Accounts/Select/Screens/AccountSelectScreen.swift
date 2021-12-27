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
//   AccountSelectScreen.swift


import Foundation
import UIKit
import MacaroonUIKit

class AccountSelectScreen: BaseViewController {
    private lazy var accountView = SelectAccountView()
    private lazy var searchEmptyStateView = SearchEmptyView()
    private lazy var theme = Theme()

    private lazy var dataSource = AccountSelectScreenDataSource(session: session)

    private var draft: SendTransactionDraft

    private let algorandSDK = AlgorandSDK()

    override func customizeTabBarAppearence() {
        isTabBarHidden = false
    }

    init(draft: SendTransactionDraft, configuration: ViewControllerConfiguration) {
        self.draft = draft
        super.init(configuration: configuration)
    }

    override func linkInteractors() {
        dataSource.delegate = self
        accountView.searchInputView.delegate = self
        accountView.listView.delegate = self
        accountView.listView.dataSource = dataSource
        accountView.clipboardView.copyButton.addTarget(
            self,
            action: #selector(didTapCopy),
            for: .touchUpInside
        )
        accountView.nextButton.addTarget(
            self,
            action: #selector(didTapNext),
            for: .touchUpInside
        )
    }

    override func configureAppearance() {
        super.configureAppearance()
        searchEmptyStateView.setTitle("account-select-search-empty-title".localized)
        searchEmptyStateView.setDetail("account-select-search-empty-detail".localized)
    }

    override func prepareLayout() {
        addAccountView()
    }

    override func bindData() {
        super.bindData()

        guard let address = UIPasteboard.general.validAddress else {
            accountView.displayClipboard(isVisible: false)
            return
        }

        accountView.displayClipboard(isVisible: true)
        accountView.clipboardView.bindData(AccountClipboardViewModel(address))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.loadData()
    }
}

extension AccountSelectScreen {
    private func addAccountView() {
        view.addSubview(accountView)
        accountView.snp.makeConstraints {
            $0.top.safeEqualToTop(of: self)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension AccountSelectScreen {
    @objc
    private func didTapCopy() {
        if let address = UIPasteboard.general.validAddress {
            accountView.searchInputView.setText(address)
        }
    }

    @objc
    private func didTapNext() {
        guard let address = accountView.searchInputView.text,
              algorandSDK.isValidAddress(address) else {
                  return
        }

        draft.toAddress = address
        // next screen
    }
}

extension AccountSelectScreen: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: theme.cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)

        if let contact = dataSource.item(at: indexPath) as? Contact {
            draft.toContact = contact
        } else if let account = dataSource.item(at: indexPath) as? Account {
            draft.toAddress = account.address
        } else {
            return
        }

        // next screen
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if dataSource.list[section].isEmpty {
            return .zero
        }
        
        return CGSize(
            width: collectionView.frame.size.width,
            height: theme.headerHeight
        )
    }
}

extension AccountSelectScreen: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        accountView.nextButton.isHidden = true

        if dataSource.isEmpty {
            accountView.listView.contentState = .empty(searchEmptyStateView)
            return
        }

        guard let query = view.text,
            !query.isEmpty else {
                accountView.listView.contentState = .none
                dataSource.search(keyword: nil)
                accountView.listView.reloadData()
                return
        }

        dataSource.search(keyword: query)


        if dataSource.isListEmtpy {
            accountView.listView.contentState = .empty(searchEmptyStateView)
        } else {
            accountView.listView.contentState = .none
        }

        if algorandSDK.isValidAddress(query) {
            accountView.listView.contentState = .none
            accountView.nextButton.isHidden = false
        }

        accountView.listView.reloadData()
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }

    func searchInputViewDidTapRightAccessory(_ view: SearchInputView) {
        let qrScannerViewController = open(.qrScanner(canReadWCSession: false), by: .push) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
}

extension AccountSelectScreen: QRScannerViewControllerDelegate {
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrText: QRText,
        completionHandler: EmptyHandler?
    ) {
        defer {
            completionHandler?()
        }

        guard let qrAddress = qrText.address else {
            return
        }

        guard algorandSDK.isValidAddress(qrAddress) else {
            return
        }

        accountView.searchInputView.setText(qrAddress)
    }

    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    ) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            completionHandler?()
        }
    }
}

extension AccountSelectScreen: AccountSelectScreenDataSourceDelegate {
    func accountSelectScreenDataSourceDidLoad(_ dataSource: AccountSelectScreenDataSource) {
        accountView.listView.reloadData()
    }
}
