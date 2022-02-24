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

//   NFTListItemReceiveView.swift

import UIKit
import MacaroonUIKit

final class NFTListItemReceiveView:
    View,
    TripleShadowDrawable {
    var thirdShadow: MacaroonUIKit.Shadow?
    var thirdShadowLayer: CAShapeLayer = CAShapeLayer()
    var secondShadow: MacaroonUIKit.Shadow?
    var secondShadowLayer: CAShapeLayer = CAShapeLayer()

    private lazy var contentView = UIView()
    private lazy var iconAndTitleContainer = UIView()
    private lazy var icon = ImageView()
    private lazy var title = Label()

    func customize(
        _ theme: NFTListItemReceiveViewTheme
    ) {
        addBackground(theme)
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension NFTListItemReceiveView {
    private func addBackground(
        _ theme: NFTListItemReceiveViewTheme
    ) {
        draw(corner: theme.containerCorner)
        draw(border: theme.containerBorder)
        draw(shadow: theme.containerFirstShadow)
        draw(secondShadow: theme.containerSecondShadow)
        draw(thirdShadow: theme.containerThirdShadow)
    }

    private func addContent(
        _ theme: NFTListItemReceiveViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.setPaddings((16, 12, 16, 12)) // Ask ??
        }

        addIconAndTitleContainer(theme)
    }

    private func addIconAndTitleContainer(
        _ theme: NFTListItemReceiveViewTheme
    ) {
        contentView.addSubview(iconAndTitleContainer)
        iconAndTitleContainer.snp.makeConstraints {
            $0.top >= 0
            $0.bottom <= 0
            $0.center == 0

            $0.setPaddings((.noMetric, 0, .noMetric, 0))
        }

        addIcon(theme)
        addTitle(theme)
    }

    private func addIcon(
        _ theme: NFTListItemReceiveViewTheme
    ) {
        icon.customizeAppearance(theme.icon)

        iconAndTitleContainer.addSubview(icon)
        icon.fitToIntrinsicSize()
        icon.snp.makeConstraints {
            $0.centerHorizontally(
                verticalPaddings: (0, .noMetric)
            )
        }
    }

    private func addTitle(
        _ theme: NFTListItemReceiveViewTheme
    ) {
        title.customizeAppearance(theme.title)
        title.contentEdgeInsets.top = theme.titleTopPadding

        iconAndTitleContainer.addSubview(title)
        title.snp.makeConstraints {
            $0.top == icon.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }
}
