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
//   AccountPortfolioView.swift

import MacaroonUIKit
import UIKit

final class AccountPortfolioView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .showMinimumBalanceInfo: TargetActionInteraction(),
        .onAmountTap: TargetActionInteraction()
    ]

    private lazy var valueView = UILabel()
    private lazy var valueButton = MacaroonUIKit.Button()
    private lazy var secondaryValueView = UILabel()
    private lazy var minimumBalanceContentView = UIView()
    private lazy var minimumBalanceTitleView = UILabel()
    private lazy var minimumBalanceValueView = UILabel()
    private lazy var minimumBalanceInfoActionView = MacaroonUIKit.Button()
    private lazy var selectedPointDateValueView = UILabel()
    
    // MARK: - Initialisers
    
    init() {
        super.init(frame: .zero)
        setupGestures()
    }
    
    // MARK: - Setups
    
    private func setupGestures() {
        startPublishing(event: .onAmountTap, for: valueButton)
    }
    
    func customize(
        _ theme: AccountPortfolioViewTheme
    ) {
        addValue(theme)
        addSecondaryValue(theme)
        addMinimumBalanceContent(theme)
        addSelectedPointDateValue(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: AccountPortfolioViewModel?
    ) {
        if let primaryValue = viewModel?.primaryValue {
            primaryValue.load(in: valueView)
        } else {
            valueView.text = nil
            valueView.attributedText = nil
        }
        
        if let secondaryValue = viewModel?.secondaryValue {
            secondaryValue.load(in: secondaryValueView)
        } else {
            secondaryValueView.text = nil
            secondaryValueView.attributedText = nil
        }
        
        if let minimumBalanceTitle = viewModel?.minimumBalanceTitle {
            minimumBalanceTitle.load(in: minimumBalanceTitleView)
        } else {
            minimumBalanceTitleView.text = nil
            minimumBalanceTitleView.attributedText = nil
        }
        
        if let minimumBalanceValue = viewModel?.minimumBalanceValue {
            minimumBalanceValue.load(in: minimumBalanceValueView)
        } else {
            minimumBalanceValueView.text = nil
            minimumBalanceValueView.attributedText = nil
        }
        
        if let selectedPointDateValue = viewModel?.selectedPointDateValue {
            [minimumBalanceTitleView, minimumBalanceValueView, minimumBalanceInfoActionView].forEach {
                $0.isHidden = true
            }
            selectedPointDateValue.load(in: selectedPointDateValueView)
        } else {
            [minimumBalanceTitleView, minimumBalanceValueView, minimumBalanceInfoActionView].forEach {
                $0.isHidden = false
            }
            selectedPointDateValueView.text = nil
            selectedPointDateValueView.attributedText = nil
        }
    }
    
    class func calculatePreferredSize(
        _ viewModel: AccountPortfolioViewModel?,
        for theme: AccountPortfolioViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let valueSize = viewModel.primaryValue?.boundingSize(
            multiline: false,
            fittingSize: .greatestFiniteMagnitude
        ) ?? .zero
        let secondaryValueSize = viewModel.secondaryValue?.boundingSize(
            multiline: false,
            fittingSize: .greatestFiniteMagnitude
        ) ?? .zero
        let preferredHeight =
            valueSize.height +
            theme.spacingBetweenTitleAndValue +
            secondaryValueSize.height
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AccountPortfolioView {
    private func addValue(
        _ theme: AccountPortfolioViewTheme
    ) {
        valueView.customizeAppearance(theme.value)
        
        [valueView, valueButton].forEach(addSubview)
        
        valueView.fitToIntrinsicSize()
        valueView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
        
        valueButton.snp.makeConstraints {
            $0.edges.equalTo(valueView)
        }
    }

    private func addSecondaryValue(
        _ theme: AccountPortfolioViewTheme
    ) {
        secondaryValueView.customizeAppearance(theme.secondaryValue)

        addSubview(secondaryValueView)
        secondaryValueView.fitToIntrinsicSize()
        secondaryValueView.snp.makeConstraints {
            $0.top == valueView.snp.bottom + theme.spacingBetweenTitleAndValue
            $0.leading == 0
            $0.bottom.equalToSuperview()
        }
    }

    private func addMinimumBalanceContent(
        _ theme: AccountPortfolioViewTheme
    ) {
        addSubview(minimumBalanceContentView)
        minimumBalanceContentView.snp.makeConstraints {
            $0.centerY == secondaryValueView.snp.centerY
            $0.trailing == 0
        }

        addMinimumBalanceTitle(theme)
        addMinimumBalanceValue(theme)
        addMinimumBalanceInfoAction(theme)
    }

    private func addMinimumBalanceTitle(
        _ theme: AccountPortfolioViewTheme
    ) {
        minimumBalanceTitleView.customizeAppearance(theme.minimumBalanceTitle)

        minimumBalanceContentView.addSubview(minimumBalanceTitleView)
        minimumBalanceTitleView.fitToHorizontalIntrinsicSize(compression: .defaultLow)
        minimumBalanceTitleView.snp.makeConstraints {
            $0.width >= self * theme.minimumBalanceTitleMinWidthRatio

            let iconHeight = theme.minimumBalanceInfoAction.icon?[.normal]?.height ?? .zero
            $0.greaterThanHeight(iconHeight)

            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addMinimumBalanceValue(
        _ theme: AccountPortfolioViewTheme
    ) {
        minimumBalanceValueView.customizeAppearance(theme.minimumBalanceValue)

        minimumBalanceContentView.addSubview(minimumBalanceValueView)
        minimumBalanceValueView.fitToHorizontalIntrinsicSize(compression: .defaultHigh)
        minimumBalanceValueView.snp.makeConstraints {
            $0.height == minimumBalanceTitleView
            $0.top == 0
            $0.leading == minimumBalanceTitleView.snp.trailing + theme.spacingBetweenMinimumBalanceTitleAndMinimumBalanceValue
            $0.bottom == 0
        }
    }

    private func addMinimumBalanceInfoAction(
        _ theme: AccountPortfolioViewTheme
    ) {
        minimumBalanceInfoActionView.customizeAppearance(theme.minimumBalanceInfoAction)

        minimumBalanceContentView.addSubview(minimumBalanceInfoActionView)
        minimumBalanceInfoActionView.fitToHorizontalIntrinsicSize()
        minimumBalanceInfoActionView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == minimumBalanceValueView.snp.trailing + theme.spacingBetweenMinimumBalanceValueAndMinimumBalanceInfoAction
            $0.trailing == 0
        }

        startPublishing(
            event: .showMinimumBalanceInfo,
            for: minimumBalanceInfoActionView
        )
    }
    
    private func addSelectedPointDateValue(
        _ theme: AccountPortfolioViewTheme
    ) {
        selectedPointDateValueView.customizeAppearance(theme.secondaryValue)
        
        addSubview(selectedPointDateValueView)
        selectedPointDateValueView.snp.makeConstraints {
            $0.centerY == secondaryValueView.snp.centerY
            $0.trailing == 0
        }
    }
}

extension AccountPortfolioView {
    enum Event {
        case showMinimumBalanceInfo
        case onAmountTap
    }
}
