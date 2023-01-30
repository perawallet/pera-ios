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

//   CollectibleGalleryGridLoadingView.swift

import UIKit
import MacaroonUIKit

final class CollectibleGalleryGridLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var managementItemView = ManagementItemView()
    private lazy var uiActionsView = CollectibleGalleryUIActionsView()
    private lazy var collectibleListItemsVerticalStack = UIStackView()

    private static let managementItemViewModel = ManagementItemViewModel(
        .collectible(
            count: .zero,
            isWatchAccountDisplay: false
        )
    )

    private static let rowCount = 2
    private static let columnCount = 2

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: CollectibleGalleryGridLoadingViewTheme
    ) {
        addManagementItem(theme)
        addUIActions(theme)
        addCollectibleListItemsVerticalStack(theme)
        addCollectibleListItem(theme)
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

    class func calculatePreferredSize(
        for theme: CollectibleGalleryGridLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width

        let managementItemSize = ManagementItemView.calculatePreferredSize(
            CollectibleGalleryGridLoadingView.managementItemViewModel,
            for: theme.managementItemTheme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        let rowCount = CollectibleGalleryGridLoadingView.rowCount
        let columnCount = CollectibleGalleryGridLoadingView.columnCount

        let rowSpacing = theme.collectibleListItemsHorizontalStackSpacing
        let itemWidth = (width - rowSpacing) / columnCount.cgFloat

        let itemHeight =  CollectibleListItemLoadingView.calculatePreferredSize(
            for: theme.collectibleListItemLoadingViewTheme,
            fittingIn: CGSize((itemWidth.float(), size.height))
        )

        let collectibleListItemsVerticalStackItemsHeight = itemHeight.height * rowCount.cgFloat

        let preferredHeight =
        theme.managementItemTopPadding +
        managementItemSize.height +
        theme.uiActionsHeight +
        theme.uiActionsPaddings.top +
        theme.collectibleListItemsVerticalStackPaddings.top +
        theme.collectibleListItemsVerticalStackSpacing +
        collectibleListItemsVerticalStackItemsHeight +
        theme.collectibleListItemsVerticalStackPaddings.bottom

        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectibleGalleryGridLoadingView {
    private func addManagementItem(
        _ theme: CollectibleGalleryGridLoadingViewTheme
    ) {
        managementItemView.customize(theme.managementItemTheme)
        managementItemView.bindData(CollectibleGalleryGridLoadingView.managementItemViewModel)

        addSubview(managementItemView)
        managementItemView.snp.makeConstraints {
            $0.top == theme.managementItemTopPadding
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addUIActions(
        _ theme: CollectibleGalleryGridLoadingViewTheme
    ) {
        uiActionsView.customize(theme.uiActions)

        addSubview(uiActionsView)
        uiActionsView.snp.makeConstraints {
            $0.top == managementItemView.snp.bottom + theme.uiActionsPaddings.top
            $0.leading == theme.uiActionsPaddings.leading
            $0.trailing == theme.uiActionsPaddings.trailing

            $0.fitToHeight(theme.uiActionsHeight)
        }
    }

    private func addCollectibleListItemsVerticalStack(
        _ theme: CollectibleGalleryGridLoadingViewTheme
    ) {
        collectibleListItemsVerticalStack.axis = .vertical
        collectibleListItemsVerticalStack.spacing = theme.collectibleListItemsVerticalStackSpacing
        collectibleListItemsVerticalStack.distribution = .equalSpacing

        addSubview(collectibleListItemsVerticalStack)

        collectibleListItemsVerticalStack.snp.makeConstraints {
            $0.top == uiActionsView.snp.bottom + theme.collectibleListItemsVerticalStackPaddings.top
            $0.leading == theme.collectibleListItemsVerticalStackPaddings.leading
            $0.trailing == theme.collectibleListItemsVerticalStackPaddings.trailing
            $0.bottom == theme.collectibleListItemsVerticalStackPaddings.bottom
        }
    }

    private func addCollectibleListItem(
        _ theme: CollectibleGalleryGridLoadingViewTheme
    ) {
        let rowCount = CollectibleGalleryGridLoadingView.rowCount
        let columnCount = CollectibleGalleryGridLoadingView.columnCount

        (0..<rowCount).forEach { _ in
            let collectibleListItemsHorizontalStack = UIStackView()
            collectibleListItemsHorizontalStack.spacing = theme.collectibleListItemsHorizontalStackSpacing
            collectibleListItemsHorizontalStack.distribution = .fillEqually

            (0..<columnCount).forEach { _ in
                let collectibleListItem = CollectibleListItemLoadingView()
                collectibleListItem.customize(theme.collectibleListItemLoadingViewTheme)
                collectibleListItemsHorizontalStack.addArrangedSubview(collectibleListItem)
            }

            collectibleListItemsVerticalStack.addArrangedSubview(collectibleListItemsHorizontalStack)
        }
    }
}
