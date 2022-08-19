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

//   PrimaryListItemView.swift

import Foundation
import MacaroonUIKit
import UIKit
import MacaroonURLImage

final class PrimaryListItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var iconView = URLImageView()
    private lazy var contentView = UIView()
    private lazy var titleView = PrimaryTitleView()
    private lazy var valueView = PrimaryTitleView()

    func customize(
        _ theme: PrimaryListItemViewTheme
    ) {
        addIcon(theme)
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: PrimaryListItemViewModel?
    ) {
        iconView.load(from: viewModel?.imageSource)
        titleView.bindData(viewModel?.title)
        valueView.bindData(viewModel?.value)
    }

    class func calculatePreferredSize(
        _ viewModel: PrimaryListItemViewModel?,
        for theme: PrimaryListItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let primaryTitleViewSize = PrimaryTitleView.calculatePreferredSize(
            viewModel.title,
            for: theme.title,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        let secondaryTitleViewSize = PrimaryTitleView.calculatePreferredSize(
            viewModel.value,
            for: theme.value,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        let titleHeight = max(primaryTitleViewSize.height, secondaryTitleViewSize.height)
        return CGSize((size.width, min(titleHeight.ceil(), size.height)))
    }

    func prepareForReuse() {
        iconView.prepareForReuse()
        titleView.prepareForReuse()
        valueView.prepareForReuse()
    }
}

extension PrimaryListItemView {
    private func addIcon(
        _ theme: PrimaryListItemViewTheme
    ) {
        iconView.build(theme.icon)
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.leading == 0
            $0.centerY == 0
        }
    }

    private func addContent(
        _ theme: PrimaryListItemViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.contentHorizontalPadding
            $0.bottom == 0
            $0.trailing == 0
        }

        addTitle(theme)
        addValue(theme)
    }

    private func addTitle(
        _ theme: PrimaryListItemViewTheme
    ) {
        titleView.customize(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.width >= contentView * theme.contentMinWidthRatio
            $0.top >= 0
            $0.leading == 0
            $0.bottom <= 0
            $0.centerY == 0
        }
    }

    private func addValue(
        _ theme: PrimaryListItemViewTheme
    ) {
        valueView.customize(theme.value)

        contentView.addSubview(valueView)
        valueView.snp.makeConstraints {
            $0.top >= 0
            $0.leading >= titleView.snp.trailing + theme.minSpacingBetweenTitleAndValue
            $0.bottom == 0
            $0.trailing <= 0
            $0.centerY == 0
        }
    }
}
