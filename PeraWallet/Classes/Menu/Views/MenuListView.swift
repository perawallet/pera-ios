// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MenuListView.swift

import UIKit
import MacaroonUIKit

final class MenuListView: View {
    private lazy var theme = MenuListViewTheme()
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.collectionViewEdgeInsets)
        collectionView.register(MenuListViewCell.self)
        collectionView.register(MenuListCardViewCell.self)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }
    
    func customize(_ theme: MenuListViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addCollectionView()
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension MenuListView {
    private func addCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
}
