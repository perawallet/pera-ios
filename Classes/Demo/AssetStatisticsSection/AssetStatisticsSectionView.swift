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

//   AssetStatisticsSectionView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AssetStatisticsSectionView:
    MacaroonUIKit.View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .showTotalSupplyInfo: GestureInteraction()
    ]
    
    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var titleView = Label()
    private lazy var priceView = PrimaryTitleView()
    private lazy var totalSupplyView = PrimaryTitleView()
    
    func customize(
        _ theme: AssetStatisticsSectionViewTheme
    ) {
        addContent(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: AssetStatisticsSectionViewModel?
    ) {
        viewModel?.title?.load(in: titleView)
        priceView.bindData(viewModel?.price)
        totalSupplyView.bindData(viewModel?.totalSupply)
    }
}

extension AssetStatisticsSectionView {
    private func addContent(
        _ theme: AssetStatisticsSectionViewTheme
    ) {
        addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.bottom == theme.contentEdgeInsets.bottom
            $0.trailing == theme.contentEdgeInsets.trailing
        }
        
        addTitle(theme)
        addPrice(theme)
        addTotalSupply(theme)
    }
    
    private func addTitle(
        _ theme: AssetStatisticsSectionViewTheme
    ) {
        contentView.addSubview(titleView)
        
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }
    
    private func addPrice(
        _ theme: AssetStatisticsSectionViewTheme
    ) {
        contentView.addSubview(priceView)
        priceView.customize(theme.price)
        
        priceView.fitToIntrinsicSize()
        priceView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndStatistics
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == contentView.snp.centerX - theme.statisticsItemSpacing
        }
    }
    
    private func addTotalSupply(
        _ theme: AssetStatisticsSectionViewTheme
    ) {
        contentView.addSubview(totalSupplyView)
        totalSupplyView.customize(theme.totalSupply)
        
        totalSupplyView.fitToIntrinsicSize()
        totalSupplyView.snp.makeConstraints {
            $0.top == priceView.snp.top
            $0.leading == contentView.snp.centerX + theme.statisticsItemSpacing
            $0.bottom == 0
            $0.trailing <= 0
        }
        
        startPublishing(
            event: .showTotalSupplyInfo,
            for: totalSupplyView
        )
    }
}

extension AssetStatisticsSectionView {
    enum Event {
        case showTotalSupplyInfo
    }
}
