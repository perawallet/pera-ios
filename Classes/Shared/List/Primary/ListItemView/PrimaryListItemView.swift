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

final class PrimaryListItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var iconView = ImageView()
    private lazy var contentView = UIView()
    private lazy var primaryTitleView = PrimaryTitleView()
    private lazy var secondaryTitleView = PrimaryTitleView()

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
}

extension PrimaryListItemView {
    private func addIcon(
        _ theme: PrimaryListItemViewTheme
    ) {
        if let iconStyle = theme.icon {
            iconView.customizeAppearance(iconStyle)
        }

        addSubview(iconView)
        iconView.contentEdgeInsets = theme.iconContentEdgeInsets ?? (0, 0)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.leading == 0
            $0.centerY == 0
            $0.top <= 0
            $0.bottom <= 0
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

        addPrimaryTitle(theme)
        addSecondaryTitle(theme)
    }

    private func addPrimaryTitle(
        _ theme: PrimaryListItemViewTheme
    ) {
        primaryTitleView.customize(theme.primaryTitle)

        contentView.addSubview(primaryTitleView)
        primaryTitleView.snp.makeConstraints {
            $0.width >= contentView * theme.contentMinWidthRatio
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addSecondaryTitle(
        _ theme: PrimaryListItemViewTheme
    ) {
        secondaryTitleView.customize(theme.secondaryTitle)

        contentView.addSubview(secondaryTitleView)
        secondaryTitleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == contentView.snp.trailing + theme.minSpacingBetweenTitles
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension PrimaryListItemView {
    func bindData(
        _ viewModel: PrimaryListItemViewModel?
    ) {
        iconView.image = viewModel?.icon?.uiImage
        primaryTitleView.bindData(viewModel?.primaryTitleViewModel)
        secondaryTitleView.bindData(viewModel?.secondaryTitleViewModel)
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
            viewModel.primaryTitleViewModel,
            for: theme.primaryTitle,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        let secondaryTitleViewSize = PrimaryTitleView.calculatePreferredSize(
            viewModel.secondaryTitleViewModel,
            for: theme.secondaryTitle,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        let iconSize = viewModel.icon?.uiImage.size ?? .zero
        let titleHeight = max(primaryTitleViewSize.height, secondaryTitleViewSize.height)
        let preferredHeight = max(iconSize.height, titleHeight)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension PrimaryListItemView {
    func prepareForReuse() {
        iconView.image = nil
        primaryTitleView.prepareForReuse()
        secondaryTitleView.prepareForReuse()
    }
}
