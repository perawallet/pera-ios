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
//   WCGroupTransactionView.swift

import UIKit

class WCGroupTransactionView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCGroupTransactionViewDelegate?

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 12.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(
            WCGroupTransactionItemCell.self,
            forCellWithReuseIdentifier: WCGroupTransactionItemCell.reusableIdentifier
        )
        collectionView.register(
            WCGroupTransactionSupplementaryHeaderView.self,
            forSupplementaryViewOfKind: WCGroupTransactionSupplementaryHeaderView.reuseIdentifier
        )
        return collectionView
    }()

    private lazy var confirmButton = MainButton(title: "title-confirm".localized)

    private lazy var declineButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(Colors.ButtonText.tertiary)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTitle("title-confirm-all".localized)
    }()

    override func setListeners() {
        super.setListeners()
        confirmButton.addTarget(self, action: #selector(confirmSigningTransaction), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(declineSigningTransaction), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupTransactionViewLayout()
        setupDeclineButtonLayout()
        setupConfirmButtonLayout()
    }
}

extension WCGroupTransactionView {
    private func setupTransactionViewLayout() {
        addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.verticalInset)
        }
    }

    private func setupDeclineButtonLayout() {
        addSubview(declineButton)

        declineButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.buttonHeight)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.verticalInset)
        }
    }

    private func setupConfirmButtonLayout() {
        addSubview(confirmButton)

        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(declineButton.snp.bottom).offset(layout.current.buttonInset)
        }
    }
}

extension WCGroupTransactionView {
    @objc
    private func confirmSigningTransaction() {
        delegate?.wcGroupTransactionViewDidConfirmSigning(self)
    }

    @objc
    private func declineSigningTransaction() {
        delegate?.wcGroupTransactionViewDidDeclineSigning(self)
    }

    @objc
    private func openLongDappMessageScreen() {
        delegate?.wcGroupTransactionViewDidOpenLongMessage(self)
    }
}

extension WCGroupTransactionView {
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        collectionView.delegate = delegate
    }

    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        collectionView.dataSource = dataSource
    }
}

extension WCGroupTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonInset: CGFloat = 16.0
        let buttonHeight: CGFloat = 52.0
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 16.0
    }
}

protocol WCGroupTransactionViewDelegate: AnyObject {
    func wcGroupTransactionViewDidOpenLongMessage(_ wcGroupTransactionView: WCGroupTransactionView)
    func wcGroupTransactionViewDidConfirmSigning(_ wcGroupTransactionView: WCGroupTransactionView)
    func wcGroupTransactionViewDidDeclineSigning(_ wcGroupTransactionView: WCGroupTransactionView)
}
