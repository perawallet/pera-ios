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
//   UnavailableAccountOptionsViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class UnavailableAccountOptionsViewController: BaseViewController {
    weak var delegate: UnavailableAccountOptionsViewControllerDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var theme = Theme()

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(OptionsCell.self)
        collectionView.register(header: AccountPortfolioErrorSupplementaryView.self)
        return collectionView
    }()

    private let account: AccountInformation
    private let options = Options.allCases

    init(account: AccountInformation, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }

    override func linkInteractors() {
        listView.delegate = self
        listView.dataSource = self
    }

    override func prepareLayout() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addListView()
    }
}

extension UnavailableAccountOptionsViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension UnavailableAccountOptionsViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .preferred(theme.modalHeight)
    }
}

extension UnavailableAccountOptionsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(OptionsCell.self, at: indexPath)
        let remoteAccount = Account(localAccount: account)
        cell.bindData(UnavailableAccountOptionsViewModel(option: options[indexPath.item], account: remoteAccount))
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        return collectionView.dequeueHeader(
            AccountPortfolioErrorSupplementaryView.self,
            at: indexPath
        )
    }
}

extension UnavailableAccountOptionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let isCopyAddressCell = indexPath.row == 0
        return CGSize(isCopyAddressCell ? theme.copyAddressCellSize : theme.defaultCellSize)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(theme.headerSize)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.item]
        dismissScreen()
        delegate?.unavailableAccountOptionsViewControllerDidTakeAction(self, for: selectedOption)
    }
}

extension UnavailableAccountOptionsViewController {
    enum Options: Int, CaseIterable {
        case copyAddress = 0
        case viewPassphrase = 1
        case showQR = 2
    }
}

protocol UnavailableAccountOptionsViewControllerDelegate: AnyObject {
    func unavailableAccountOptionsViewControllerDidTakeAction(
        _ viewController: UnavailableAccountOptionsViewController,
        for option: UnavailableAccountOptionsViewController.Options
    )
}
