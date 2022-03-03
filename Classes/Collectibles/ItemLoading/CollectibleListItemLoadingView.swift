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

//   CollectibleListItemLoadingView.swift

import UIKit
import MacaroonUIKit

final class CollectibleListItemLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var image = ShimmerView()
    private lazy var title = ShimmerView()
    private lazy var subtitle = ShimmerView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: CollectibleListItemLoadingViewTheme
    ) {
        addImage(theme)
        addTitle(theme)
        addSubtitle(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func linkInteractors() {
        isUserInteractionEnabled = false
    }
}

extension CollectibleListItemLoadingView {
    private func addImage(
        _ theme: CollectibleListItemLoadingViewTheme
    ) {
        image.draw(corner: theme.corner)

        addSubview(image)
        image.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
            $0.width == snp.width
            $0.height == image.snp.width
        }
    }

    private func addTitle(
        _ theme: CollectibleListItemLoadingViewTheme
    ) {
        title.draw(corner: theme.corner)

        addSubview(title)
        title.snp.makeConstraints {
            $0.top == image.snp.bottom + theme.titleTopPadding
            $0.leading == 0
            $0.width.equalToSuperview().multipliedBy(theme.titleWidthMultiplier)
            $0.fitToHeight(theme.titleViewHeight)
        }
    }

    private func addSubtitle(
        _ theme: CollectibleListItemLoadingViewTheme
    ) {
        subtitle.draw(corner: theme.corner)

        addSubview(subtitle)
        subtitle.snp.makeConstraints {
            $0.top == title.snp.bottom + theme.subtitleTopPadding
            $0.leading == 0
            $0.bottom == 0
            $0.width.equalToSuperview().multipliedBy(theme.subtitleWidthMultiplier)
            $0.fitToHeight(theme.subtitleViewHeight)
        }
    }
}
