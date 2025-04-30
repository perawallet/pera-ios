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

//
//   HDWalletListItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HDWalletListItemView: View {
    
    private lazy var theme = HDWalletListItemViewTheme()
    
    private lazy var iconView = UIView()
    private lazy var titleView = UILabel()
    private lazy var subtitleView = UILabel()
    private lazy var mainCurrencyView = UILabel()
    private lazy var secondaryCurrencyView = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    func customize(
        _ theme: HDWalletListItemViewTheme
    ) {
        addIcon(theme)
        addTitle(theme)
        addSubtitle(theme)
        addMainCurrency(theme)
        addSecondaryCurrency(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: HDWalletItemViewModel?
    ) {
        titleView.text = viewModel?.title?.string
        subtitleView.text = viewModel?.subtitle?.string
        mainCurrencyView.text = viewModel?.mainCurrency?.string
        secondaryCurrencyView.text = viewModel?.secondaryCurrency?.string
    }
}

extension HDWalletListItemView {
    private func addIcon(
        _ theme: HDWalletListItemViewTheme
    ) {
        let icon = ImageView()
        icon.customizeAppearance(theme.icon)
        iconView.backgroundColor = Colors.Button.Secondary.background.uiColor
        iconView.layer.cornerRadius = theme.iconViewCornerRadius
        iconView.addSubview(icon)
        
        icon.snp.makeConstraints {
            $0.center == iconView.snp.center
        }
        
        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == 0
            $0.fitToSize(theme.iconViewSize)
        }
    }
    
    private func addTitle(
        _ theme: HDWalletListItemViewTheme
    ) {
        titleView.customizeAppearance(theme.titleTheme.title)

        addSubview(titleView)
        
        titleView.snp.makeConstraints {
            $0.top == theme.titleTheme.spacing
            $0.leading == iconView.snp.trailing + theme.titleTheme.spacing
            $0.trailing == 0
        }
    }
    
    private func addSubtitle(
        _ theme: HDWalletListItemViewTheme
    ) {
        subtitleView.customizeAppearance(theme.titleTheme.subtitle)

        addSubview(subtitleView)
        
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.bottom == theme.titleTheme.spacing
            $0.leading == iconView.snp.trailing + theme.titleTheme.spacing
            $0.trailing == 0
        }
    }
    
    
    private func addMainCurrency(
        _ theme: HDWalletListItemViewTheme
    ) {
        mainCurrencyView.customizeAppearance(theme.currencyTheme.main)

        addSubview(mainCurrencyView)
        
        mainCurrencyView.snp.makeConstraints {
            $0.centerY == titleView.snp.centerY
            $0.trailing == 0
        }
    }
    
    private func addSecondaryCurrency(
        _ theme: HDWalletListItemViewTheme
    ) {
        secondaryCurrencyView.customizeAppearance(theme.currencyTheme.secondary)

        addSubview(secondaryCurrencyView)
        
        secondaryCurrencyView.snp.makeConstraints {
            $0.top == mainCurrencyView.snp.bottom
            $0.bottom == theme.titleTheme.spacing
            $0.trailing == 0
        }
    }
}
