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

//
//   HomeLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomeLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var theme = HomeLoadingViewTheme()

    private lazy var portfolioLabel = UILabel()
    private lazy var infoActionView = MacaroonUIKit.Button()
    private lazy var portfolioLoading = ShimmerView()
    private lazy var portfolioCurrencyLoading = ShimmerView()
    
    private lazy var quickActionsView = QuickActionsView()
    
    private lazy var accountsLabel = Label()
    private lazy var firstAccountPreviewLoading = PreviewLoadingView()
    private lazy var secondAccountPreviewLoading = PreviewLoadingView()
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        addPortfolioView()
        addQuickActionsView()
        addAccountCells()
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension HomeLoadingView {
    private func addPortfolioView() {
        portfolioLabel.editText = theme.portfolioText

        addSubview(portfolioLabel)
        portfolioLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.portfolioMargin.top)
            $0.centerX.equalToSuperview()
        }
        
        infoActionView.customizeAppearance(theme.infoAction)
        
        addSubview(infoActionView)
        infoActionView.snp.makeConstraints{
            $0.centerY == portfolioLabel
            $0.leading == portfolioLabel.snp.trailing + theme.spacingBetweenTitleAndInfoAction
        }

        portfolioLoading.draw(corner: theme.loadingCorner)

        addSubview(portfolioLoading)
        portfolioLoading.snp.makeConstraints {
            $0.top.equalTo(portfolioLabel.snp.bottom).offset(theme.portfolioLoadingMargin.top)
            $0.centerX.equalToSuperview()
            $0.fitToSize(theme.portfolioLoadingSize)
        }
        
        portfolioCurrencyLoading.draw(corner: theme.loadingCorner)

        addSubview(portfolioCurrencyLoading)
        portfolioCurrencyLoading.snp.makeConstraints {
            $0.top.equalTo(portfolioLoading.snp.bottom).offset(theme.portfolioCurrencyLoadingMargin.top)
            $0.centerX.equalToSuperview()
            $0.fitToSize(theme.portfolioCurrencyLoadingSize)
        }
    }

    private func addQuickActionsView() {
        quickActionsView.customize(theme.quickActionsTheme)

        let actionSize = QuickActionsView.calculatePreferredSize(
            for: theme.quickActionsTheme,
            fittingIn: CGSize(width: UIScreen.main.bounds.width - theme.quickActionsMargin.trailing - theme.quickActionsMargin.leading,
                              height: .greatestFiniteMagnitude)
        )

        addSubview(quickActionsView)
        quickActionsView.snp.makeConstraints {
            $0.top.equalTo(portfolioCurrencyLoading.snp.bottom).offset(theme.quickActionsMargin.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(actionSize.height)
        }
    }

    private func addAccountCells() {
        accountsLabel.customizeAppearance(theme.accountsLabelStyle)

        addSubview(accountsLabel)
        accountsLabel.snp.makeConstraints {
            $0.top.equalTo(quickActionsView.snp.bottom).offset(theme.accountsLabelMargin.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        firstAccountPreviewLoading.customize(PreviewLoadingViewCommonTheme())
        secondAccountPreviewLoading.customize(PreviewLoadingViewCommonTheme())

        addSubview(firstAccountPreviewLoading)
        firstAccountPreviewLoading.snp.makeConstraints {
            $0.top.equalTo(accountsLabel.snp.bottom).offset(theme.accountLoadingMargin.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(theme.accountLoadingHeight)
        }
        
        addSubview(secondAccountPreviewLoading)
        secondAccountPreviewLoading.snp.makeConstraints {
            $0.top.equalTo(firstAccountPreviewLoading.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(theme.accountLoadingHeight)
        }
    }
}
