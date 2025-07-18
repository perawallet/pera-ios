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
//   HomePortfolioView.swift

import MacaroonUIKit
import UIKit

final class HomePortfolioView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .showInfo: TargetActionInteraction(),
        .onAmountTap: TargetActionInteraction()
    ]
    
    var isPrivacyModeTooltipVisible: Bool = false {
        didSet { update(isPrivacyModeTooltipVisible: isPrivacyModeTooltipVisible) }
    }

    private(set) lazy var titleView = Label()
    private lazy var infoActionView = MacaroonUIKit.Button()
    private lazy var valueView = Label()
    private lazy var valueButton = MacaroonUIKit.Button()
    private lazy var secondaryValueView = Label()
    private lazy var selectedPointDateValueView = Label()
    
    private lazy var tooltipController = TooltipUIController(presentingView: self)
    
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
        _ theme: HomePortfolioViewTheme
    ) {
        addTitle(theme)
        addInfoAction(theme)
        addValue(theme)
        addSecondaryValue(theme)
        addSelectedPointDateValue(theme)
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
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        titleView.textColor = viewModel?.titleColor
        infoActionView.tintColor = viewModel?.titleColor

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
        
        if let selectedPointDateValue = viewModel?.selectedPointDateValue {
            selectedPointDateValue.load(in: selectedPointDateValueView)
        } else {
            selectedPointDateValueView.text = nil
            selectedPointDateValueView.attributedText = nil
        }
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
        let titleSize = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let valueSize = viewModel.primaryValue?.boundingSize(
            multiline: false,
            fittingSize: .greatestFiniteMagnitude
        ) ?? .zero
        let secondaryValueSize = viewModel.secondaryValue?.boundingSize(
            multiline: false,
            fittingSize: .greatestFiniteMagnitude
        ) ?? .zero
        let preferredHeight =
            theme.titleTopPadding +
            titleSize.height +
            theme.spacingBetweenTitleAndValue +
            valueSize.height +
            theme.spacingBetweenTitleAndValue +
            secondaryValueSize.height
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
    
    // MARK: - Actions
    
    private func update(isPrivacyModeTooltipVisible: Bool) {
        
        guard isPrivacyModeTooltipVisible else {
            tooltipController.dismiss()
            return
        }
        
        tooltipController.present(on: valueView, title: String(localized: "tooltip-privacy-mode"))
    }
}

extension HomePortfolioView {
    private func addTitle(
        _ theme: HomePortfolioViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        
        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == theme.titleTopPadding
            $0.leading == 0
        }
    }
    
    private func addInfoAction(
        _ theme: HomePortfolioViewTheme
    ) {
        infoActionView.customizeAppearance(theme.infoAction)
        
        addSubview(infoActionView)
        infoActionView.snp.makeConstraints{
            $0.centerY == titleView
            $0.leading == titleView.snp.trailing + theme.spacingBetweenTitleAndInfoAction
        }

        startPublishing(
            event: .showInfo,
            for: infoActionView
        )
    }
    
    private func addValue(
        _ theme: HomePortfolioViewTheme
    ) {
        valueView.customizeAppearance(theme.value)
        
        valueView.adjustsFontSizeToFitWidth = true
        valueView.minimumScaleFactor = 14/36
        
        [valueView, valueButton].forEach(addSubview)
        
        valueView.fitToIntrinsicSize()
        valueView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndValue
            $0.leading == 0
        }
        
        valueButton.snp.makeConstraints {
            $0.edges.equalTo(valueView)
        }
    }
    
    private func addSecondaryValue(
        _ theme: HomePortfolioViewTheme
    ) {
        secondaryValueView.customizeAppearance(theme.secondaryValue)
        
        secondaryValueView.adjustsFontSizeToFitWidth = true
        secondaryValueView.minimumScaleFactor = 14/36
        
        addSubview(secondaryValueView)
        secondaryValueView.fitToIntrinsicSize()
        secondaryValueView.snp.makeConstraints {
            $0.top == valueView.snp.bottom + theme.spacingBetweenTitleAndValue
            $0.leading == 0
            $0.bottom == 0
        }
    }
    
    private func addSelectedPointDateValue(
        _ theme: HomePortfolioViewTheme
    ) {
        selectedPointDateValueView.customizeAppearance(theme.secondaryValue)
        
        selectedPointDateValueView.adjustsFontSizeToFitWidth = true
        selectedPointDateValueView.minimumScaleFactor = 14/36
        
        addSubview(selectedPointDateValueView)
        selectedPointDateValueView.fitToIntrinsicSize()
        selectedPointDateValueView.snp.makeConstraints {
            $0.centerY == secondaryValueView.snp.centerY
            $0.trailing == 0
            $0.bottom == 0
        }
    }
}

extension HomePortfolioView {
    enum Event {
        case showInfo
        case onAmountTap
    }
}
