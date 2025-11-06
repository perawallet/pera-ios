// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ASAMarketsFragmentMarketView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASAMarketsFragmentMarketView:
    UIView,
    CornerDrawable,
    UIInteractable {
    var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .market: GestureInteraction()
    ]

    private lazy var contentView = HStackView()
    private lazy var titleView = Label()
    private lazy var subtitleView = Label()
    private lazy var accessoryIcon = ImageView()

    private var lastContentSize: CGSize = .zero
    private var theme = ASAMarketsFragmentMarketViewTheme()

    override var intrinsicContentSize: CGSize {
        CGSize((UIView.noIntrinsicMetric, theme.height))
    }

    func customize(_ theme: ASAMarketsFragmentMarketViewTheme) {
        self.theme = theme

        customizeAppearance(theme.background)
        draw(corner: theme.backgroundCorner)
        addTitleView(theme)
        addAccessoryIcon(theme)
        addSubtitleView(theme)
        

        startPublishing(event: .market, for: self)
    }

    static func calculatePreferredSize(
        _ viewModel: ASADetailMarketViewModel?,
        for layoutSheet: ASADetailMarketViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return .zero
    }
}

extension ASAMarketsFragmentMarketView {
    private func addTitleView(_ theme: ASAMarketsFragmentMarketViewTheme) {
        titleView.customizeAppearance(theme.titleStyle)
        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == theme.titleLeading
        }
    }
    
    private func addAccessoryIcon(_ theme: ASAMarketsFragmentMarketViewTheme) {
        accessoryIcon.customizeAppearance(theme.detailImage)
        addSubview(accessoryIcon)
        accessoryIcon.snp.makeConstraints {
            $0.trailing == theme.accessoryIconTrailing
            $0.centerY == 0
            $0.width.equalTo(theme.accessoryIconSize.w)
            $0.height.equalTo(theme.accessoryIconSize.h)
        }
    }
    
    private func addSubtitleView(_ theme: ASAMarketsFragmentMarketViewTheme) {
        subtitleView.customizeAppearance(theme.subtitleStyle)
        addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.centerY == 0
            $0.trailing == accessoryIcon.snp.leading + theme.subtitleTrailing
        }
    }
}

extension ASAMarketsFragmentMarketView {
    enum Event {
        case market
    }
}
