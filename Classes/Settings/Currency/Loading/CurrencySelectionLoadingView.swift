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

//   CurrencySelectionLoadingView.swift

import MacaroonUIKit
import UIKit

final class CurrencySelectionLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var title = ShimmerView()
    private lazy var subtitle = ShimmerView()
    private lazy var searchInput = SearchInputView()
    private lazy var currencySelectionItemsStack = UIStackView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: CurrencySelectionLoadingViewTheme
    ) {
        addTitle(theme)
        addSubtitle(theme)
        addCurrencySelectionItemsStack(theme)
    }

    func linkInteractors() {
        isUserInteractionEnabled = false
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension CurrencySelectionLoadingView {
    private func addTitle(
        _ theme: CurrencySelectionLoadingViewTheme
    ) {
        title.draw(corner: theme.corner)

        addSubview(title)
        title.snp.makeConstraints {
            $0.fitToSize(theme.titleSize)
            $0.top == theme.titleTopPadding
            $0.leading == 0
        }
    }

    private func addSubtitle(
        _ theme: CurrencySelectionLoadingViewTheme
    ) {
        subtitle.draw(corner: theme.corner)

        addSubview(subtitle)
        subtitle.snp.makeConstraints {
            $0.fitToSize(theme.subtitleSize)
            $0.top == title.snp.bottom + theme.subtitleTopPadding
            $0.leading == 0
        }
    }

    private func addSearchInput(
        _ theme: CurrencySelectionLoadingViewTheme
    ) {
        searchInput.customize(theme.searchInputTheme)

        addSubview(searchInput)
        searchInput.snp.makeConstraints {
            $0.fitToHeight(theme.searchInputHeight)
            $0.top == subtitle.snp.bottom + theme.searchInputTopPadding
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addCurrencySelectionItemsStack(
        _ theme: CurrencySelectionLoadingViewTheme
    ) {
        currencySelectionItemsStack.axis = .vertical
        currencySelectionItemsStack.spacing = theme.currencySelectionItemsStackSpacing
        currencySelectionItemsStack.distribution = .equalSpacing
        currencySelectionItemsStack.alignment = .top

        addSubview(currencySelectionItemsStack)
        currencySelectionItemsStack.snp.makeConstraints {
            $0.top == subtitle.snp.bottom + theme.currencySelectionItemsStackTopPadding
            $0.leading.trailing.bottom == 0
        }

        addSelectionItem(theme.xlargeItemWidth)
        addSelectionItem(theme.mediumItemWidth)
        addSelectionItem(theme.largeItemWidth)
        addSelectionItem(theme.smallItemWidth)
    }

    private func addSelectionItem(
        _ theme: CurrencySelectionItemLoadingViewTheme
    ) {
        let item = CurrencySelectionItemLoadingView()
        item.customize(theme)

        currencySelectionItemsStack.addArrangedSubview(item)
    }
}
