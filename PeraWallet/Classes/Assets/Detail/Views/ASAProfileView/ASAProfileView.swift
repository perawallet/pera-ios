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

//   ASAProfileView.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit
import SwiftUI
import pera_wallet_core

enum ASAProfileViewType {
    case assetDetail
    case assetPrice
    case assetDescovery
}

final class ASAProfileView:
    UIView,
    ViewModelBindable,
    UIInteractable {
    var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .layoutChanged: UIBlockInteraction(),
        .onAmountTap: TargetActionInteraction()
    ]
    
    var onPeriodChange: ((ChartDataPeriod) -> Void)?
    var onPointSelected: ((ChartDataPoint?) -> Void)?

    private(set) var intrinsicExpandedContentSize: CGSize = .zero
    private(set) var intrinsicCompressedContentSize: CGSize = .zero

    private(set) var isLayoutLoaded = false

    private lazy var contentView = VStackView()
    private lazy var iconView = URLImageView()
    private lazy var titleView = UIView()
    private lazy var nameView = RightAccessorizedLabel()
    private lazy var primaryValueView = UILabel()
    private lazy var primaryValueButton = MacaroonUIKit.Button()
    private lazy var secondaryValueAndSelectedPointView = UIView()
    private lazy var secondaryValueView = UILabel()
    private lazy var tendencyValueView = ChartTendencyView()
    private lazy var selectedPointDateValueView = Label()
    
    private var chartData: ChartViewData?
    private lazy var chartViewModel = ChartViewModel(dataModel: ChartDataModel())
    private lazy var chartHostingController = UIHostingController(rootView: makeChartView())
    
    private var theme = ASAProfileViewTheme()
    private let type: ASAProfileViewType
    
    // MARK: - Initialisers
    
    @MainActor init(type: ASAProfileViewType = .assetDetail) {
        self.type = type
        super.init(frame: .zero)
        setupGestures()
        setupViewModelCallback()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeChartView() -> ChartView {
        return ChartView(viewModel: chartViewModel)
    }
    
    // MARK: - Setups
    
    private func setupGestures() {
        startPublishing(event: .onAmountTap, for: primaryValueButton)
    }
    
    private func setupViewModelCallback() {
        chartViewModel.onSelectedPeriodChanged = { [weak self] newPeriod in
            guard let self else { return }
            onPeriodChange?(newPeriod)
        }
        
        chartViewModel.onPointSelected = { [weak self] selectedPointVM in
            guard let self else { return }
            guard let selectedPointVM else {
                onPointSelected?(nil)
                return
            }
            onPointSelected?(chartData?.chartValues[selectedPointVM.day])
        }
    }

    func customize(_ theme: ASAProfileViewTheme) {
        self.theme = theme

        addContent(theme)
    }

    func bindData(_ viewModel: ASAProfileViewModel?) {
        if let selectedPointDateValue = viewModel?.selectedPointDateValue {
            selectedPointDateValue.load(in: selectedPointDateValueView)
            tendencyValueView.isHidden = true
        } else {
            [selectedPointDateValueView].forEach {
                $0.text = nil
                $0.attributedText = nil
            }
            tendencyValueView.isHidden = false
            bindIcon(viewModel)
            nameView.bindData(viewModel?.name)
        }
        
        let valueToLoad = (type == .assetPrice ? viewModel?.priceValue : viewModel?.primaryValue)
        if let value = valueToLoad {
            value.load(in: primaryValueView)
        } else {
            primaryValueView.text = nil
            primaryValueView.attributedText = nil
        }
        
        if let secondaryValue = viewModel?.secondaryValue {
            secondaryValue.load(in: secondaryValueView)
            secondaryValueView.alpha = (type == .assetPrice ? 0 : 1)
        } else {
            secondaryValueView.text = nil
            secondaryValueView.attributedText = nil
        }
    }
    
    func updateChart(with data: ChartViewData?, and tendenciesVM: TendenciesViewModel) {
        guard let data else {
            contentView.removeArrangedSubview(chartHostingController.view)
            chartHostingController.view.removeFromSuperview()
            return
        }
        chartData = data
        chartViewModel.refresh(with: data.model)
        chartHostingController.rootView = makeChartView()
        
        guard
            let differenceText = tendenciesVM.differenceText,
            let differenceInPercentageText = tendenciesVM.differenceInPercentageText,
            let arrowImageView = tendenciesVM.arrowImageView
        else {
            tendencyValueView.isHidden = true
            return
        }
        
        tendencyValueView.bind(
            differenceText: differenceText,
            differenceInPercentageText: differenceInPercentageText,
            arrowImageView: arrowImageView,
            hideDiffLabel: type == .assetPrice,
            baselineView: secondaryValueView
        )
        
        tendencyValueView.isHidden = false
    }

    func bindIcon(_ viewModel: ASAProfileViewModel?) {
        iconView.load(from: viewModel?.icon)
    }

    static func calculatePreferredSize(
        _ viewModel: ASAProfileViewModel?,
        for layoutSheet: ASAProfileViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return .zero
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty { return }

        isLayoutLoaded = true
    }
}

extension ASAProfileView {
    private func addContent(_ theme: ASAProfileViewTheme) {
        addSubview(contentView)
        contentView.alignment = .leading
        contentView.distribution = .fill
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addTitle(theme)
        addPrimaryValue(theme)
        addSecondaryValueAndSelectPointDate(theme)
        
        guard type != .assetDescovery else { return }
        addChartView(theme)
    }

    private func addTitle(_ theme: ASAProfileViewTheme) {
        contentView.addArrangedSubview(titleView)
        
        titleView.snp.makeConstraints {
            $0.height.equalTo(theme.titleViewHeight)
        }

        addIcon(theme)
        addName(theme)
    }
    
    private func addIcon(_ theme: ASAProfileViewTheme) {
        iconView.build(theme.icon)

        titleView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.expandedIconSize)
            $0.leading == 0
        }
    }

    private func addName(_ theme: ASAProfileViewTheme) {
        nameView.customize(theme.name)

        titleView.addSubview(nameView)
        nameView.fitToVerticalIntrinsicSize()
        nameView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.nameViewLeading
            $0.bottom == 0
        }
    }

    private func addPrimaryValue(_ theme: ASAProfileViewTheme) {
        primaryValueView.customizeAppearance(theme.primaryValue)
        primaryValueView.addSubview(primaryValueButton)

        contentView.addArrangedSubview(primaryValueView)
        primaryValueView.fitToVerticalIntrinsicSize()
        contentView.setCustomSpacing(
            theme.spacingBetweenTitleAndPrimaryValue,
            after: titleView
        )
        
        primaryValueButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addSecondaryValueAndSelectPointDate(_ theme: ASAProfileViewTheme) {
        secondaryValueView.customizeAppearance(theme.secondaryValue)
        selectedPointDateValueView.customizeAppearance(theme.secondaryValue)
        
        [secondaryValueView, tendencyValueView, selectedPointDateValueView].forEach {
            secondaryValueAndSelectedPointView.addSubview($0)
        }
        
        secondaryValueView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        if type == .assetPrice {
            tendencyValueView.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.leading == secondaryValueView.snp.leading
            }
        } else {
            tendencyValueView.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.leading == secondaryValueView.snp.trailing + theme.tendencyValueViewLeading
            }
        }

        selectedPointDateValueView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        contentView.addArrangedSubview(secondaryValueAndSelectedPointView)
        
        secondaryValueAndSelectedPointView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        contentView.setCustomSpacing(
            theme.spacingBetweenPrimaryValueAndSecondValue,
            after: primaryValueView
        )
    }
    
    private func addChartView(_ theme: ASAProfileViewTheme) {
        contentView.addArrangedSubview(chartHostingController.view)
        
        chartHostingController.view.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.chartViewLeadingOffset)
            $0.trailing.equalToSuperview().offset(theme.chartViewTrailingOffset)
            $0.height.equalTo(theme.chartViewHeight)
        }
        
        chartHostingController.view.fitToVerticalIntrinsicSize()
        contentView.setCustomSpacing(
            theme.spacingBetweenPrimaryValueAndSecondValue,
            after: secondaryValueAndSelectedPointView
        )
        
        contentView.layoutIfNeeded()
    }
}

extension ASAProfileView {
    enum Event {
        case layoutChanged
        case onAmountTap
    }
}
