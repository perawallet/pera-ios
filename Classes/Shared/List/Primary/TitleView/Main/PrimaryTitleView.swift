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

//   PrimaryTitleView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class PrimaryTitleView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var titleView = Label()
    private lazy var iconView = ImageView()
    private lazy var subtitleView = Label()

    func customize(
        _ theme: PrimaryTitleViewTheme
    ) {
        addTitle(theme)
        addIcon(theme)
        addSubtitle(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension PrimaryTitleView {
    private func addTitle(
        _ theme: PrimaryTitleViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addIcon(
        _ theme: PrimaryTitleViewTheme
    ) {
        if let iconStyle = theme.icon {
            iconView.customizeAppearance(iconStyle)
        }

        addSubview(iconView)
        iconView.contentEdgeInsets = theme.iconContentEdgeInsets ?? (0, 0)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.leading == titleView.snp.trailing
            $0.trailing <= 0
            $0.centerY == titleView
        }
    }

    private func addSubtitle(
        _ theme: PrimaryTitleViewTheme
    ) {
        subtitleView.customizeAppearance(theme.subtitle)

        addSubview(subtitleView)
        subtitleView.contentEdgeInsets.top = theme.spacingBetweenTitleAndSubtitle
        subtitleView.fitToVerticalIntrinsicSize()
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension PrimaryTitleView {
    func bindData(
        _ viewModel: PrimaryTitleViewModel?
    ) {
        titleView.editText = viewModel?.title
        iconView.image = viewModel?.icon?.uiImage
        subtitleView.editText = viewModel?.subtitle
    }

    class func calculatePreferredSize(
        _ viewModel: PrimaryTitleViewModel?,
        for theme: PrimaryTitleViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let subtitleSize = viewModel.subtitle.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let accessoryIconSize = viewModel.icon?.uiImage.size ?? .zero
        let contentHeight = max(titleSize.height, accessoryIconSize.height) + subtitleSize.height
        let preferredHeight = contentHeight
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension PrimaryTitleView {
    func prepareForReuse() {
        titleView.editText = nil
        iconView.image = nil
        subtitleView.editText = nil
    }
}
