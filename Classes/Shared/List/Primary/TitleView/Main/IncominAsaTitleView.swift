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

//   IncominAsaTitleView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class IncominAsaTitleView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var primaryTitleView = Label()
    private lazy var primaryTitleAccessoryView = ImageView()
    private lazy var secondaryTitleView = Label()
    private lazy var secondSecondaryTitleView = Label()

    func customize(
        _ theme: IncominAsaTitleViewTheme
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
        _ viewModel: IncominAsaTitleViewModel?
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
        // TODO:  get value
        if let seconsSecondaryTitle = viewModel?.SecondSecondaryTitle {
            seconsSecondaryTitle.load(in: secondSecondaryTitleView)
        } else {
//            secondSecondaryTitleView.clearText()
        }
    }

    class func calculatePreferredSize(
        _ viewModel: IncominAsaTitleViewModel?,
        for theme: IncominAsaTitleViewTheme,
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

extension IncominAsaTitleView {
    private func addPrimaryTitle(
        _ theme: IncominAsaTitleViewTheme
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
        _ theme: IncominAsaTitleViewTheme
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
        _ theme: IncominAsaTitleViewTheme
    ) {
//        secondaryTitleView.customizeAppearance(theme.secondaryTitle)
        secondaryTitleView.textColor = #colorLiteral(red: 0.5180481076, green: 0.5191512704, blue: 0.5520042777, alpha: 1)
        secondaryTitleView.backgroundColor = #colorLiteral(red: 0.9562577605, green: 0.9563563466, blue: 0.9594090581, alpha: 1)
        secondaryTitleView.draw(corner: Corner.init(radius: 8))
        addSubview(secondaryTitleView)
//        secondaryTitleView.fitToVerticalIntrinsicSize(
//            hugging: .required,
//            compression: .defaultHigh
//        )
        secondaryTitleView.contentEdgeInsets = (theme.spacingBetweenPrimaryAndSecondaryTitles, 6, theme.spacingBetweenPrimaryAndSecondaryTitles, 6)
        secondaryTitleView.snp.makeConstraints {
            $0.top == primaryTitleView.snp.bottom + 6
            $0.leading == 0
            $0.bottom == 0
//            $0.trailing == 0
            $0.width <= 72
        }
    }
    
    private func addSecondSecondaryTitle(
        _ theme: IncominAsaTitleViewTheme
    ) {
//        secondSecondaryTitleView.customizeAppearance(theme.secondaryTitle)
        secondSecondaryTitleView.textColor = #colorLiteral(red: 0.5180481076, green: 0.5191512704, blue: 0.5520042777, alpha: 1)
        secondSecondaryTitleView.backgroundColor = #colorLiteral(red: 0.9562577605, green: 0.9563563466, blue: 0.9594090581, alpha: 1)
        secondSecondaryTitleView.draw(corner: Corner.init(radius: 8))
        addSubview(secondSecondaryTitleView)
//        secondSecondaryTitleView.fitToVerticalIntrinsicSize(
//            hugging: .required,
//            compression: .defaultHigh
//        )
        
        secondSecondaryTitleView.contentEdgeInsets = (theme.spacingBetweenPrimaryAndSecondaryTitles, 6, theme.spacingBetweenPrimaryAndSecondaryTitles, 6)
        secondSecondaryTitleView.snp.makeConstraints {
            $0.top == primaryTitleView.snp.bottom + 6
            $0.leading == secondaryTitleView.snp.trailing + 6
            $0.bottom == 0
//            $0.trailing == 0
            $0.width <= 72
        }
    }
}
