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

//   CurrencySelectionItemLoadingView.swift

import UIKit
import MacaroonUIKit

final class CurrencySelectionItemLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var title = ShimmerView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: CurrencySelectionItemLoadingViewTheme
    ) {
        addTitle(theme)
    }

    func linkInteractors() {
        isUserInteractionEnabled = false
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    class func calculatePreferredSize(
        for theme: CurrencySelectionItemLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let preferredHeight =
            theme.titleTopPadding +
            theme.titleViewHeight +
            theme.titleBottomPadding

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CurrencySelectionItemLoadingView {
    private func addTitle(
        _ theme: CurrencySelectionItemLoadingViewTheme
    ) {
        title.draw(corner: theme.corner)

        addSubview(title)
        title.snp.makeConstraints {
            $0.fitToHeight(theme.titleViewHeight)
            $0.fitToWidth(theme.titleViewWidth)
            $0.top == theme.titleTopPadding
            $0.leading == 0
            $0.bottom == theme.titleBottomPadding
        }
    }
}
