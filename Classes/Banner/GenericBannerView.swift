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

//   GenericBannerView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class GenericBannerView:
    View,
    ViewModelBindable,
    UIInteractionObservable,
    UIControlInteractionPublisher,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .action: UIControlInteraction()
    ]

    private lazy var stackView = VStackView()
    private lazy var titleView = Label()
    private lazy var subtitleView = Label()
    private lazy var closeButton = MacaroonUIKit.Button()
    private lazy var actionView = MacaroonUIKit.Button()
    private lazy var imageView = Label()
    
    func customize(
        _ theme: GenericBannerViewTheme
    ) {
        addStackView(theme)
        addTitle(theme)
        addSubtitle(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: HomePortfolioViewModel?
    ) {
        titleView.editText = viewModel?.title
        titleView.textColor = viewModel?.titleColor
    }
    
    class func calculatePreferredSize(
        _ viewModel: HomePortfolioViewModel?,
        for theme: HomePortfolioViewTheme,
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
        let valueSize = viewModel.value.boundingSize(
            multiline: false,
            fittingSize: .greatestFiniteMagnitude
        )
        let holdingsMaxWidth =
            (width - theme.minSpacingBetweenAlgoHoldingsAndAssetHoldings) / 2
        let algoHoldingsSize = HomePortfolioItemView.calculatePreferredSize(
            viewModel.algoHoldings,
            for: theme.algoHoldings,
            fittingIn: CGSize((holdingsMaxWidth, .greatestFiniteMagnitude))
        )
        let assetHoldingsSize = HomePortfolioItemView.calculatePreferredSize(
            viewModel.assetHoldings,
            for: theme.assetHoldings,
            fittingIn: CGSize((holdingsMaxWidth, .greatestFiniteMagnitude))
        )
        let preferredHeight =
            theme.titleTopPadding +
            titleSize.height +
            theme.spacingBetweenTitleAndValue +
            valueSize.height +
            theme.spacingBetweenValueAndHoldings +
            max(algoHoldingsSize.height, assetHoldingsSize.height) +
            theme.buyAlgoButtonHeight +
            theme.buyAlgoButtonMargin.top
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension GenericBannerView {
    private func addStackView(
        _ theme: GenericBannerViewTheme
    ) {
        addSubview(stackView)
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
            $0.bottom <= 0
        }
    }
    
    private func addTitle(
        _ theme: GenericBannerViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        
        stackView.addArrangedSubview(titleView)
    }
    
    private func addSubtitle(
        _ theme: GenericBannerViewTheme
    ) {
        subtitleView.customizeAppearance(theme.subtitle)
        
        stackView.addArrangedSubview(titleView)
    }
}

extension GenericBannerView {
    enum Event {
        case action
    }
}
