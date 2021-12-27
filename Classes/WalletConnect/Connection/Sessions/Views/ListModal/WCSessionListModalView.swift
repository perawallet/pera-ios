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
//   WCSessionListModalView.swift

import UIKit
import MacaroonUIKit

final class WCSessionListModalView: View {
    weak var delegate: WCSessionListModalViewDelegate?

    private lazy var theme = WCSessionListModalViewTheme()

    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.contentInset)
        collectionView.register(WCSessionListModalItemCell.self)
        return collectionView
    }()

    private lazy var closeButton = ViewFactory.Button.makeSecondaryButton("title-close".localized)

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
        setListeners()
    }

    private func customize(_ theme: WCSessionListModalViewTheme) {
        addCollectionView()
        addCloseButton(theme)
    }

    func setListeners() {
        closeButton.addTarget(self, action: #selector(notifyDelegateToCloseModal), for: .touchUpInside)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }

    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension WCSessionListModalView {
    @objc
    private func notifyDelegateToCloseModal() {
        delegate?.wcSessionListModalViewDidTapCloseButton(self)
    }
}

extension WCSessionListModalView {
    private func addCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addCloseButton(_ theme: WCSessionListModalViewTheme) {
        addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }
}

extension WCSessionListModalView {
    func setCollectionViewDelegate(_ delegate: UICollectionViewDelegate?) {
        collectionView.delegate = delegate
    }

    func setCollectionViewDataSource(_ dataSource: UICollectionViewDataSource?) {
        collectionView.dataSource = dataSource
    }
}

protocol WCSessionListModalViewDelegate: AnyObject {
    func wcSessionListModalViewDidTapCloseButton(_ wcSessionListModalView: WCSessionListModalView)
}
