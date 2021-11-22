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
//   AccountRecoverOptionsViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class AccountRecoverOptionsViewController: BaseViewController, BottomSheetPresentable {
    weak var delegate: AccountRecoverOptionsViewControllerDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var optionsView = OptionsView()
    private lazy var theme = Theme()

    var modalHeight: ModalHeight {
        return .preferred(theme.modalHeight)
    }

    private let options: [Option] = [.paste, .scanQR, .info]

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func linkInteractors() {
        optionsView.optionsCollectionView.delegate = self
        optionsView.optionsCollectionView.dataSource = self
    }

    override func prepareLayout() {
        optionsView.customize(theme.optionsViewTheme)
        view.addSubview(optionsView)

        optionsView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension AccountRecoverOptionsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(OptionsCell.self, at: indexPath)
        if let option = options[safe: indexPath.item] {
            cell.customize(OptionsContextViewTheme())
            cell.bind(AccountRecoverOptionsViewModel(option))
        }

        return cell
    }
}

extension AccountRecoverOptionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedOption = options[safe: indexPath.item] else {
            return
        }

        switch selectedOption {
        case .paste:
            dismissScreen()
            delegate?.accountRecoverOptionsViewControllerDidPasteFromClipboard(self)
        case .scanQR:
            dismissScreen()
            delegate?.accountRecoverOptionsViewControllerDidOpenScanQR(self)
        case .info:
            dismissScreen()
            delegate?.accountRecoverOptionsViewControllerDidOpenMoreInfo(self)
        }
    }
}

extension AccountRecoverOptionsViewController {
    enum Option: Int, CaseIterable {
        case paste = 0
        case scanQR = 1
        case info = 2
    }
}

protocol AccountRecoverOptionsViewControllerDelegate: AnyObject {
    func accountRecoverOptionsViewControllerDidOpenScanQR(_ viewController: AccountRecoverOptionsViewController)
    func accountRecoverOptionsViewControllerDidPasteFromClipboard(_ viewController: AccountRecoverOptionsViewController)
    func accountRecoverOptionsViewControllerDidOpenMoreInfo(_ viewController: AccountRecoverOptionsViewController)
}
