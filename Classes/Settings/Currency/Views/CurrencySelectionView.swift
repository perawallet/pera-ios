// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CurrencySelectionView.swift

import MacaroonUIKit
import UIKit

final class CurrencySelectionView: View {
    private lazy var theme = CurrencySelectionViewTheme()
    
    private lazy var searchInputView = SearchInputView()
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        flowLayout.minimumInteritemSpacing = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.collectionViewEdgeInsets)
        return collectionView
    }()
    
    func customize(_ theme: CurrencySelectionViewTheme) {
        addSearchInputView(theme)
        addCollectionView(theme)
    }
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension CurrencySelectionView {
    private func addSearchInputView(_ theme: CurrencySelectionViewTheme) {
        searchInputView.customize(theme.searchInputViewTheme)
        
        addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.searchViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    
    private func addCollectionView(_ theme: CurrencySelectionViewTheme) {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchInputView.snp.bottom).offset(theme.collectionViewTopPadding)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension CurrencySelectionView {
    func setCollectionViewDelegate(_ delegate: UICollectionViewDelegate?) {
        collectionView.delegate = delegate
    }
    
    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        collectionView.dataSource = dataSource
    }
    
    func setSearchInputDelegate(_ delegate: SearchInputViewDelegate?) {
        searchInputView.delegate = delegate
    }
    
    func resetSearchInputView() {
        searchInputView.setText(nil)
    }
}
