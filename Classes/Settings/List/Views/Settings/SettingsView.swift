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
//  SettingsView.swift

import UIKit
import MacaroonUIKit

final class SettingsView: View {
    private lazy var theme = SettingsViewTheme()

    private lazy var titleView = UILabel()
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionInset = UIEdgeInsets(theme.sectionInset)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.collectionViewEdgeInsets)
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.register(SettingsDetailCell.self, forCellWithReuseIdentifier: SettingsDetailCell.reusableIdentifier)
        collectionView.register(SettingsToggleCell.self, forCellWithReuseIdentifier: SettingsToggleCell.reusableIdentifier)
        collectionView.register(
            SettingsFooterSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: SettingsFooterSupplementaryView.reusableIdentifier
        )
        collectionView.register(
            SingleGrayTitleHeaderSuplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SingleGrayTitleHeaderSuplementaryView.reusableIdentifier
        )
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }
    
    func customize(_ theme: SettingsViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addTitleView()
        addCollectionView()
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension SettingsView {
    private func addTitleView() {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.titleTopInset)
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.trailing.equalToSuperview()
        }
    }
    
    private func addCollectionView() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(theme.collectionTopInset)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }
}
