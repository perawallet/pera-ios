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

//   NFTListItemView.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

/// <todo> Rename
final class NFTListItemView:
    UIView,
    ViewComposable,
    ViewModelBindable,
    ListReusable {
    private lazy var iconView = URLImageView()
    private lazy var loadingIndicatorView = ViewLoadingIndicator()
    private lazy var iconOverlayView = UIImageView()
    private lazy var iconBottomRightBadgeView = UIImageView()
    private lazy var titleContentView = UIView()
    private lazy var primaryTitleView = UILabel()
    private lazy var primaryTitleAccessoryView = ImageView()
    private lazy var secondaryTitleView = Label()
    private lazy var amountView = Label()

    func customize(_ theme: NFTListItemViewTheme) {
        addIcon(theme)
        addIconOverlay(theme)
        addTitleContent(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: NFTListItemViewModel?) {
        iconView.load(from: viewModel?.icon)
        iconBottomRightBadgeView.image = viewModel?.iconBottomRightBadge
        iconOverlayView.image = viewModel?.iconOverlayImage

        if let primaryTitle = viewModel?.primaryTitle {
            primaryTitle.load(in: primaryTitleView)
        } else {
            primaryTitleView.clearText()
        }

        primaryTitleAccessoryView.image = viewModel?.primaryTitleAccessory?.uiImage

        if let secondaryTitle = viewModel?.secondaryTitle {
            secondaryTitle.load(in: secondaryTitleView)
        } else {
            secondaryTitleView.clearText()
        }

        if let amount = viewModel?.amount {
            amount.load(in: amountView)
        } else {
            amountView.clearText()
        }
    }

    static func calculatePreferredSize(
        _ viewModel: NFTListItemViewModel?,
        for theme: NFTListItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let iconSize = theme.iconSize
        let titleContentWidth =
            width -
            iconSize.w -
            theme.spacingBetweenIconAndTitle

        let primaryTitleSize = viewModel.primaryTitle?.boundingSize(
            multiline: false,
            fittingSize: CGSize((titleContentWidth, .greatestFiniteMagnitude))
        ) ?? .zero
        var secondaryTitleSize = viewModel.secondaryTitle?.boundingSize(
            multiline: false,
            fittingSize: CGSize((titleContentWidth, .greatestFiniteMagnitude))
        ) ?? .zero

        if secondaryTitleSize.height > 0 {
            secondaryTitleSize.height += theme.spacingBetweenPrimaryAndSecondaryTitles
        }

        var amountSize = viewModel.amount?.boundingSize(
            multiline: false,
            fittingSize: CGSize((titleContentWidth, .greatestFiniteMagnitude))
        ) ?? .zero

        if amountSize.height > 0 {
            amountSize.height += theme.spacingBetweenPrimaryAndSecondaryTitles
        }

        let primaryTitleAccessorySize = viewModel.primaryTitleAccessory?.uiImage.size ?? .zero
        let maxPrimaryTitleSize = max(primaryTitleSize.height, primaryTitleAccessorySize.height)
        let contentHeight = maxPrimaryTitleSize + max(secondaryTitleSize.height, amountSize.height)
        let minCalculatedHeight = min(contentHeight.ceil(), size.height)
        let titleSize = CGSize((size.width, minCalculatedHeight))

        let preferredHeight = max(iconSize.h, titleSize.height)
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    func prepareForReuse() {
        iconView.prepareForReuse()
        iconBottomRightBadgeView.image = nil
        iconOverlayView.image = nil
        primaryTitleView.clearText()
        primaryTitleAccessoryView.image = nil
        secondaryTitleView.clearText()
        amountView.clearText()
    }
}

extension NFTListItemView {
    private func addIcon(_ theme: NFTListItemViewTheme) {
        iconView.build(theme.icon)
        
        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.leading == 0
            $0.centerY == 0
        }
        
        addIconBottomRightBadge(theme)
        addIconOverlay(theme)
        addLoadingIndicator(theme)
    }
    
    private func addIconOverlay(_ theme: NFTListItemViewTheme) {
        iconView.addSubview(iconOverlayView)
        iconOverlayView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
    
    private func addLoadingIndicator(_ theme: NFTListItemViewTheme) {
        loadingIndicatorView.applyStyle(theme.loadingIndicator)


        iconOverlayView.addSubview(loadingIndicatorView)
        loadingIndicatorView.snp.makeConstraints {
            $0.fitToSize(theme.loadingIndicatorSize)
            $0.center.equalToSuperview()
        }

        loadingIndicatorView.isHidden = true
    }

    private func addIconBottomRightBadge(_ theme: NFTListItemViewTheme) {
        addSubview(iconBottomRightBadgeView)
        iconBottomRightBadgeView.snp.makeConstraints {
            $0.top == iconView.snp.top + theme.iconBottomRightBadgePaddings.top
            $0.leading == theme.iconBottomRightBadgePaddings.leading
        }
    }

    private func addTitleContent(_ theme: NFTListItemViewTheme) {
        addSubview(titleContentView)
        titleContentView.snp.makeConstraints {
            $0.height >= iconView
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.spacingBetweenIconAndTitle
            $0.bottom == 0
            $0.trailing == 0
        }

        addPrimaryTitle(theme)
        addPrimaryTitleAccessory(theme)
        addSecondaryTitle(theme)
        addAmount(theme)
    }

    private func addPrimaryTitle(_ theme: NFTListItemViewTheme) {
        primaryTitleView.customizeAppearance(theme.primaryTitle)

        titleContentView.addSubview(primaryTitleView)
        primaryTitleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        primaryTitleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addPrimaryTitleAccessory(_ theme: NFTListItemViewTheme) {
        primaryTitleAccessoryView.customizeAppearance(theme.primaryTitleAccessory)

        titleContentView.addSubview(primaryTitleAccessoryView)
        primaryTitleAccessoryView.contentEdgeInsets = theme.primaryTitleAccessoryContentEdgeInsets
        primaryTitleAccessoryView.fitToIntrinsicSize()
        primaryTitleAccessoryView.snp.makeConstraints {
            $0.centerY == primaryTitleView
            $0.leading == primaryTitleView.snp.trailing
            $0.trailing <= 0
        }
    }

    private func addSecondaryTitle(_ theme: NFTListItemViewTheme) {
        secondaryTitleView.customizeAppearance(theme.secondaryTitle)

        titleContentView.addSubview(secondaryTitleView)
        secondaryTitleView.contentEdgeInsets.top = theme.spacingBetweenPrimaryAndSecondaryTitles
        secondaryTitleView.snp.makeConstraints {
            $0.top == primaryTitleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addAmount(_ theme: NFTListItemViewTheme) {
        amountView.customizeAppearance(theme.amount)

        titleContentView.addSubview(amountView)
        amountView.fitToHorizontalIntrinsicSize(hugging: .defaultLow)
        amountView.contentEdgeInsets.top = theme.spacingBetweenPrimaryAndSecondaryTitles
        amountView.snp.makeConstraints {
            $0.top == primaryTitleView.snp.bottom
            $0.leading == secondaryTitleView.snp.trailing
            $0.bottom == 0
            $0.trailing <= 0
        }
    }
}

extension NFTListItemView {
    var isLoading: Bool {
        return loadingIndicatorView.isAnimating
    }

    func startLoading() {
        loadingIndicatorView.isHidden = false

        loadingIndicatorView.startAnimating()
    }

    func stopLoading() {
        loadingIndicatorView.isHidden = true

        loadingIndicatorView.stopAnimating()
    }
}
