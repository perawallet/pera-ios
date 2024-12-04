// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncominASAListTitleView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class IncominASAListTitleView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var primaryTitleView = Label()
    private lazy var primaryTitleAccessoryView = ImageView()
    private lazy var secondaryTitleView = Label()
    private lazy var secondSecondaryTitleView = Label()

    func customize(
        _ theme: IncominASAListTitleViewTheme
    ) {
        addPrimaryTitle(theme)
        addPrimaryTitleAccessory(theme)
        addSecondaryTitle(theme)
        addSecondSecondaryTitle(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: IncominASAListTitleViewModel?
    ) {
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

        if let seconsSecondaryTitle = viewModel?.secondSecondaryTitle {
            seconsSecondaryTitle.load(in: secondSecondaryTitleView)
        } else {
            secondSecondaryTitleView.clearText()
        }
    }

    class func calculatePreferredSize(
        _ viewModel: IncominASAListTitleViewModel?,
        for theme: IncominASAListTitleViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let primaryTitleSize = viewModel.primaryTitle?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        var secondaryTitleSize = viewModel.secondaryTitle?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero

        if secondaryTitleSize.height > 0 {
            secondaryTitleSize.height += theme.spacingBetweenPrimaryAndSecondaryTitles
        }

        let primaryTitleAccessorySize = viewModel.primaryTitleAccessory?.uiImage.size ?? .zero
        let maxPrimaryTitleSize = max(primaryTitleSize.height, primaryTitleAccessorySize.height)
        let contentHeight = maxPrimaryTitleSize + secondaryTitleSize.height
        let minCalculatedHeight = min(contentHeight.ceil(), size.height)
        return CGSize((size.width, minCalculatedHeight))
    }

    func prepareForReuse() {
        primaryTitleView.clearText()
        primaryTitleAccessoryView.image = nil
        secondaryTitleView.clearText()
        secondSecondaryTitleView.clearText()
    }
}

extension IncominASAListTitleView {
    private func addPrimaryTitle(
        _ theme: IncominASAListTitleViewTheme
    ) {
        primaryTitleView.customizeAppearance(theme.primaryTitle)

        addSubview(primaryTitleView)
        primaryTitleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        primaryTitleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addPrimaryTitleAccessory(
        _ theme: IncominASAListTitleViewTheme
    ) {
        primaryTitleAccessoryView.customizeAppearance(theme.primaryTitleAccessory)

        addSubview(primaryTitleAccessoryView)
        primaryTitleAccessoryView.contentEdgeInsets = theme.primaryTitleAccessoryContentEdgeInsets
        primaryTitleAccessoryView.fitToIntrinsicSize()
        primaryTitleAccessoryView.snp.makeConstraints {
            $0.centerY == primaryTitleView
            $0.leading == primaryTitleView.snp.trailing
            $0.trailing <= 0
        }
    }

    private func addSecondaryTitle(
        _ theme: IncominASAListTitleViewTheme
    ) {
        secondaryTitleView.customizeAppearance(theme.secondaryTitle)
        secondaryTitleView.draw(corner: Corner.init(radius: 8))
        addSubview(secondaryTitleView)

        
        secondaryTitleView.contentEdgeInsets = theme.titleEdgeInsets
        secondaryTitleView.snp.makeConstraints {
            $0.top == primaryTitleView.snp.bottom + 6
            $0.leading == 0
            $0.bottom == 0
        }
    }
    
    private func addSecondSecondaryTitle(
        _ theme: IncominASAListTitleViewTheme
    ) {
        secondSecondaryTitleView.customizeAppearance(theme.secondSecondaryTitle)
        secondSecondaryTitleView.draw(corner: Corner.init(radius: 8))
        secondSecondaryTitleView.contentEdgeInsets = theme.titleEdgeInsets

        addSubview(secondSecondaryTitleView)
        secondSecondaryTitleView.snp.makeConstraints {
            $0.top == primaryTitleView.snp.bottom + 6
            $0.leading == secondaryTitleView.snp.trailing + 6
            $0.bottom == 0
        }
    }
}
