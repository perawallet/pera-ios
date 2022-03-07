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

//   CollectiblePreviewView.swift

import MacaroonUIKit
import UIKit
import MacaroonURLImage

final class CollectiblePreviewView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var placeholderView = AssetImagePlaceholderView()
    private lazy var iconView = URLImageView()
    private lazy var contentView = UIView()
    private lazy var titleView = Label()
    private lazy var subtitleView = Label()
    private lazy var accessoryView = Label()

    func customize(
        _ theme: CollectiblePreviewViewTheme
    ) {
        addPlaceholderView(theme)
        addIconView(theme)
        addContent(theme)
        addAccessory(theme)
    }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func bindData(
        _ viewModel: CollectiblePreviewViewModel?
    ) {

        placeholderView.bindData(viewModel)
        iconView.load(from: viewModel?.image) { [weak self] error in
            guard let self = self else {
                return
            }

            if error == nil {
                self.placeholderView.isHidden = true
            }
        }

        titleView.editText = viewModel?.title
        subtitleView.editText = viewModel?.subtitle
        accessoryView.editText = viewModel?.accessory
    }

    func prepareForReuse() {
        placeholderView.prepareForReuse()
        placeholderView.isHidden = false
        iconView.prepareForReuse()
        titleView.editText = nil
        subtitleView.editText = nil
        accessoryView.editText = nil
    }

    class func calculatePreferredSize(
        _ viewModel: CollectiblePreviewViewModel?,
        for theme: CollectiblePreviewViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let iconSize = theme.iconSize
        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let subtitleSize = viewModel.subtitle.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let accessorySize = viewModel.accessory.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let contentHeight = titleSize.height + subtitleSize.height
        let accessoryHeight = accessorySize.height
        let preferredHeight = max(iconSize.h, max(contentHeight, accessoryHeight))
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectiblePreviewView {
    private func addPlaceholderView(
        _ theme: CollectiblePreviewViewTheme
    ) {
        placeholderView.customize(AssetImagePlaceholderViewTheme())

        addSubview(placeholderView)
        placeholderView.fitToIntrinsicSize()
        placeholderView.snp.makeConstraints {
            $0.leading == 0
            $0.centerY == 0
            $0.fitToSize(theme.iconSize)
        }
    }

    private func addIconView(
        _ theme: CollectiblePreviewViewTheme
    ) {
        iconView.layer.draw(corner: theme.iconCorner)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.leading == 0
            $0.centerY == 0
            $0.fitToSize(theme.iconSize)
        }
    }

    private func addContent(
        _ theme: CollectiblePreviewViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width >= self * theme.contentMinWidthRatio
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.horizontalPadding
            $0.bottom == 0
        }

        addTitle(theme)
        addSubtitle(theme)
    }

    private func addTitle(
        _ theme: CollectiblePreviewViewTheme
    ) {
        titleView.customizeAppearance(theme.primaryAssetTitle)

        contentView.addSubview(titleView)

        titleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        ) /// Ask, without this there is ambiguous layout for vertical position & height.

        titleView.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultLow
        )

        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing <= 0
        }
    }

    private func addSubtitle(
        _ theme: CollectiblePreviewViewTheme
    ) {
        subtitleView.customizeAppearance(theme.secondaryAssetTitle)

        contentView.addSubview(subtitleView)

        subtitleView.fitToVerticalIntrinsicSize()
        subtitleView.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultLow
        )

        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
    }

    private func addAccessory(
        _ theme: CollectiblePreviewViewTheme
    ) {
        accessoryView.customizeAppearance(theme.accessory)

        addSubview(accessoryView)

        accessoryView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        accessoryView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )

        accessoryView.snp.makeConstraints {
            $0.top == 0
            $0.leading == contentView.snp.trailing + theme.minSpacingBetweenContentAndSecondaryContent
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
