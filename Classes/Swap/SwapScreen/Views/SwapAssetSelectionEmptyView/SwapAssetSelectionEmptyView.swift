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

//   SwapAssetSelectionEmptyView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class SwapAssetSelectionEmptyView: View {
    private lazy var titleView = Label()
    private lazy var iconView = UIImageView()
    private lazy var emptyTitleView = UILabel()
    private lazy var accessoryView = UIImageView()

    func customize(
        _ theme: SwapAssetSelectionEmptyViewTheme
    ) {
        addTitle(theme)
        addIcon(theme)
        addEmptyTitleView(theme)
        addAccessory(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: SwapAssetSelectionEmptyViewModel?
    ) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.clearText()
        }
    }
}

extension SwapAssetSelectionEmptyView {
    private func addTitle(
        _ theme: SwapAssetSelectionEmptyViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.contentEdgeInsets.bottom = theme.spacingBetweenTitleAndIcon
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addIcon(
        _ theme: SwapAssetSelectionEmptyViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addEmptyTitleView(
        _ theme: SwapAssetSelectionEmptyViewTheme
    ) {
        emptyTitleView.customizeAppearance(theme.emptyTitle)

        addSubview(emptyTitleView)
        emptyTitleView.fitToIntrinsicSize()
        emptyTitleView.snp.makeConstraints {
            $0.centerY == iconView
            $0.leading == iconView.snp.trailing + theme.emptyTitleLeadingInset
            $0.bottom <= 0
        }
    }

    private func addAccessory(
        _ theme: SwapAssetSelectionEmptyViewTheme
    ) {
        accessoryView.customizeAppearance(theme.accessory)

        addSubview(accessoryView)
        accessoryView.fitToIntrinsicSize()
        accessoryView.snp.makeConstraints {
            $0.centerY == iconView
            $0.leading == emptyTitleView.snp.trailing + theme.accessoryLeadingInset
            $0.bottom <= 0
            $0.trailing == 0
        }
    }
}
