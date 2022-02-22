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

//   NFTListLoadingView.swift

import UIKit
import MacaroonUIKit

final class NFTListLoadingView:
    View,
    ListReusable {
    private lazy var searchInput = GradientView(
        gradientStartColor: AppColors.Shared.Layer.gray.uiColor,
        gradientEndColor: AppColors.Shared.Layer.grayLighter.uiColor.withAlphaComponent(0.5)
    )

    private lazy var nftListItemsVerticalStack = UIStackView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: NFTListLoadingViewTheme
    ) {
        addSearchInput(theme)
        addNFTListItemsVerticalStack(theme)
        addNFTListItem(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func linkInteractors() {
        isUserInteractionEnabled = false
    }
}

extension NFTListLoadingView {
    private func addSearchInput(
        _ theme: NFTListLoadingViewTheme
    ) {
        searchInput.draw(corner: theme.corner)

        addSubview(searchInput)
        searchInput.snp.makeConstraints {
            $0.setPaddings(theme.searchInputPaddings)
            $0.fitToHeight(theme.searchInputHeight)
        }
    }

    private func addNFTListItemsVerticalStack(
        _ theme: NFTListLoadingViewTheme
    ) {
        nftListItemsVerticalStack.axis = .vertical
        nftListItemsVerticalStack.spacing = theme.nftListItemsVerticalStackSpacing
        nftListItemsVerticalStack.distribution = .equalSpacing

        addSubview(nftListItemsVerticalStack)

        nftListItemsVerticalStack.snp.makeConstraints {
            $0.top == searchInput.snp.bottom + theme.nftListItemsVerticalStackPaddings.top
            $0.leading == theme.nftListItemsVerticalStackPaddings.leading
            $0.trailing == theme.nftListItemsVerticalStackPaddings.trailing
            $0.bottom <= 0
        }
    }

    private func addNFTListItem(
        _ theme: NFTListLoadingViewTheme
    ) {
        let rowCount = 2
        let columnCount = 2

        (0..<rowCount).forEach { _ in
            let nftListItemsHorizontalStack = UIStackView()
            nftListItemsHorizontalStack.spacing = theme.nftListItemsHorizontalStackSpacing
            nftListItemsHorizontalStack.distribution = .fillEqually

            (0..<columnCount).forEach { _ in
                let nftListItem = NFTListItemLoadingView()
                nftListItem.customize(theme.nftListItemLoadingViewTheme)
                nftListItemsHorizontalStack.addArrangedSubview(nftListItem)
            }

            nftListItemsVerticalStack.addArrangedSubview(nftListItemsHorizontalStack)
        }
    }
}
