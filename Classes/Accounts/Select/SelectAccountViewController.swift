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
//   SelectAccountViewController.swift


import Foundation
import UIKit

final class SelectAccountViewController: BaseViewController {
    weak var delegate: SelectAccountViewControllerDelegate?

    private let theme = Theme()

    private lazy var accountListDataSource = SelectAccountViewControllerDataSource(
        session: UIApplication.shared.appConfiguration?.session
    )

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.listMinimumLineSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.listBackgroundColor
        collectionView.register(AccountPreviewCell.self)
        collectionView.contentInset.top = theme.listContentInsetTop
        return collectionView
    }()

    private let transactionAction: TransactionAction

    init(transactionAction: TransactionAction, configuration: ViewControllerConfiguration) {
        self.transactionAction = transactionAction
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }

    override func configureAppearance() {
        view.backgroundColor = AppColors.Shared.System.background.uiColor
        navigationItem.title = "send-algos-select".localized
    }

    override func setListeners() {
        listView.delegate = self
        listView.dataSource = accountListDataSource
    }

    override func prepareLayout() {
        addListView()
    }
    
}

extension SelectAccountViewController {
    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.bottom.equalToSuperview()
        }
    }
}

extension SelectAccountViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: theme.listItemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let account = accountListDataSource.accounts[safe: indexPath.item] else {
            return
        }

        delegate?.selectAccountViewController(self, didSelect: account, for: transactionAction)
    }
}

enum TransactionAction {
    case send
    case receive
}

protocol SelectAccountViewControllerDelegate: AnyObject {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for transactionAction: TransactionAction
    )
}
