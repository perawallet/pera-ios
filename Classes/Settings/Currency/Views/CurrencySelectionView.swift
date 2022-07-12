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

final class CurrencySelectionView:
    View,
    ViewModelBindable {
    private lazy var theme = CurrencySelectionViewTheme()

    private lazy var titleLabel = Label()
    private lazy var descriptionLabel = Label()
    private lazy var searchInputView = SearchInputView()
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        flowLayout.minimumInteritemSpacing = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(theme.collectionViewEdgeInsets)
        return collectionView
    }()

    private var isLoading = true {
        didSet { updateWhenLoadingDidChange() }
    }
    
    func customize(_ theme: CurrencySelectionViewTheme) {
        addTitle(theme)
        addDescription(theme)
        addSearchInputView(theme)
        addCollectionView(theme)
    }
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func bindData(
        _ viewModel: CurrencySelectionViewModel?
    ) {
        if let title = viewModel?.title {
            title.load(in: titleLabel)
        } else {
            titleLabel.text = nil
            titleLabel.attributedText = nil
        }

        if let description = viewModel?.description {
            description.load(in: descriptionLabel)
        } else {
            descriptionLabel.text = nil
            descriptionLabel.attributedText = nil
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !bounds.isEmpty {
            updateWhenViewDidLayoutSubviews()
        }
    }
}

extension CurrencySelectionView {
    func showLoading() {
        isLoading = true
    }

    func hideLoading() {
        isLoading = false
    }
}

extension CurrencySelectionView {
    private func updateWhenViewDidLayoutSubviews() {
        updateCollectionWhenViewDidLayoutSubviews()
    }

    private func updateWhenLoadingDidChange() {
        titleLabel.isHidden = isLoading
        descriptionLabel.isHidden = isLoading
        searchInputView.isHidden = isLoading

        updateCollectionWhenLoadingDidChange()
    }

    private func addTitle(_ theme: CurrencySelectionViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addDescription(_ theme: CurrencySelectionViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.descriptionTopPadding)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.trailing.equalToSuperview().inset(theme.descriptionTrailingPadding)
        }
    }

    private func addSearchInputView(_ theme: CurrencySelectionViewTheme) {
        searchInputView.customize(theme.searchInputViewTheme)
        
        addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.searchViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    
    private func addCollectionView(_ theme: CurrencySelectionViewTheme) {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func updateCollectionWhenLoadingDidChange() {
        updateCollectionWhenViewDidLayoutSubviews()
    }

    private func updateCollectionWhenViewDidLayoutSubviews() {
        let top: CGFloat
        if isLoading {
            top = 0
        } else {
            top = searchInputView.frame.maxY + theme.collectionViewTopPadding
        }

        collectionView.setContentInset(
            top: top
        )
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
