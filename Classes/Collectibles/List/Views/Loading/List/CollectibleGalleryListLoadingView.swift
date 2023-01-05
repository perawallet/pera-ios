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

//   CollectibleGalleryListLoadingView.swift

import UIKit
import MacaroonUIKit

final class CollectibleGalleryListLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var managementItemView = ManagementItemView()
    private lazy var uiActionsView = CollectibleGalleryUIActionsView()
    private lazy var collectibleListItemsContentView = VStackView()

    private static let managementItemViewModel = ManagementItemViewModel(
        .collectible(
            count: .zero,
            isWatchAccountDisplay: false
        )
    )

    override init(frame: CGRect ) {
        super.init(frame: frame)

        isUserInteractionEnabled = false
    }

    func customize(_ theme: CollectibleGalleryListLoadingViewTheme) {
        addManagementItem(theme)
        addUIActions(theme)
        addCollectibleListItemsContent(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    class func calculatePreferredSize(
        for theme: CollectibleGalleryListLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width

        let managementItemSize = ManagementItemView.calculatePreferredSize(
            CollectibleGalleryListLoadingView.managementItemViewModel,
            for: theme.managementItemTheme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        let collectibleListItemsContentHeight = theme.collectibleListItemHeight * theme.numberOfCollectibleListItems.cgFloat

        let preferredHeight =
            theme.managementItemTopPadding +
            managementItemSize.height +
            theme.uiActionsHeight +
            theme.uiActionsPaddings.top +
            theme.collectibleListItemsContentPaddings.top +
            collectibleListItemsContentHeight +
            theme.collectibleListItemsContentPaddings.bottom

        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectibleGalleryListLoadingView {
    private func addManagementItem(_ theme: CollectibleGalleryListLoadingViewTheme) {
        managementItemView.customize(theme.managementItemTheme)
        managementItemView.bindData(CollectibleGalleryListLoadingView.managementItemViewModel)

        addSubview(managementItemView)
        managementItemView.snp.makeConstraints {
            $0.top == theme.managementItemTopPadding
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addUIActions(_ theme: CollectibleGalleryListLoadingViewTheme) {
        uiActionsView.customize(theme.uiActions)

        addSubview(uiActionsView)
        uiActionsView.snp.makeConstraints {
            $0.top == managementItemView.snp.bottom + theme.uiActionsPaddings.top
            $0.leading == theme.uiActionsPaddings.leading
            $0.trailing == theme.uiActionsPaddings.trailing
            $0.fitToHeight(theme.uiActionsHeight)
        }
    }

    private func addCollectibleListItemsContent(_ theme: CollectibleGalleryListLoadingViewTheme) {
        addSubview(collectibleListItemsContentView)
        collectibleListItemsContentView.snp.makeConstraints {
            $0.top == uiActionsView.snp.bottom + theme.collectibleListItemsContentPaddings.top
            $0.leading == theme.collectibleListItemsContentPaddings.leading
            $0.trailing == theme.collectibleListItemsContentPaddings.trailing
            $0.bottom == theme.collectibleListItemsContentPaddings.bottom
        }

        addCollectibleListItems(theme)
    }

    private func addCollectibleListItems(_ theme: CollectibleGalleryListLoadingViewTheme) {
        (1...theme.numberOfCollectibleListItems).forEach { i in
            let view = PreviewLoadingView()
            view.customize(theme.collectibleListItem)
            view.snp.makeConstraints {
                $0.fitToHeight(theme.collectibleListItemHeight)
            }
            collectibleListItemsContentView.addArrangedSubview(view)

            if i != theme.numberOfCollectibleListItems {
                view.addSeparator(theme.collectibleListItemSeparator)
            }
        }
    }
}
