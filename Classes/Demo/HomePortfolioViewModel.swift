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
//   HomePortfolioViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct HomePortfolioViewModel:
    PairedViewModel,
    Hashable {
    private(set) var totalValueResult: PortfolioHandle = .failure(.idle)
    private(set) var title: EditText?
    private(set) var titleColor: UIColor?
    private(set) var value: EditText?
    private(set) var secondaryValue: EditText?
    
    init(
        _ model: Portfolio
    ) {
        bind(model)
    }
}

extension HomePortfolioViewModel {
    mutating func bind(
        _ portfolio: Portfolio
    ) {
        var mPortfolio = portfolio
        mPortfolio.calculate()
        
        bindTitle(mPortfolio)
        bindValue(mPortfolio)
        bindSecondaryValue(mPortfolio.totalValueResult)
    }
    
    mutating func bindTitle(
        _ portfolio: Portfolio
    ) {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        title = .attributedString(
            "portfolio-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
            )
        
        switch portfolio.totalValueResult {
        case .success:
            titleColor = AppColors.Components.Text.gray.uiColor
        case .failure:
            titleColor = AppColors.Shared.Helpers.negative.uiColor
        }
    }
    
    mutating func bindValue(
        _ portfolio: Portfolio
    ) {
        totalValueResult = portfolio.totalValueResult
        
        let font = Fonts.DMSans.medium.make(36)
        let lineHeightMultiplier = 1.02
        
        value = .attributedString(
            totalValueResult.primaryUIDescription.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier),
                    .textAlignment(.center)
                ])
            ])
        )
    }
    
    mutating func bindSecondaryValue(
        _ totalValue: PortfolioHandle
    ) {
        totalValueResult = totalValue
        
        let font = Fonts.DMSans.medium.make(15)
        let lineHeightMultiplier = 1.02
        
        secondaryValue = .attributedString(
            ("≈ " + totalValueResult.secondaryUIDescription).attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier),
                    .textAlignment(.center)
                ])
            ])
        )
    }
}

extension HomePortfolioViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(value)
    }
    
    static func == (
        lhs: HomePortfolioViewModel,
        rhs: HomePortfolioViewModel
    ) -> Bool {
        return
            lhs.value == rhs.value
    }
}
