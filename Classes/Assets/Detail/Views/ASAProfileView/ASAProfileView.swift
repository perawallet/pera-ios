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

final class ASAProfileView:
    UIView,
    ViewModelBindable,
    UIInteractable {
    var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .layoutChanged: UIBlockInteraction(),
        .copyAssetID: GestureInteraction(gesture: .longPress),
        .onAmountTap: TargetActionInteraction()
    ]
    
    var onPeriodChange: ((ChartDataPeriod) -> Void)?
    var onPointSelected: ((ChartDataPoint?) -> Void)?

    private(set) var intrinsicExpandedContentSize: CGSize = .zero
    private(set) var intrinsicCompressedContentSize: CGSize = .zero

    private(set) var isLayoutLoaded = false

    private lazy var expandedContentView = VStackView()
    private lazy var compressedContentView = UIStackView()
    private lazy var iconView = URLImageView()
    private lazy var titleView = UIView()
    private lazy var nameView = RightAccessorizedLabel()
    private lazy var titleSeparatorView = Label()
    private lazy var idView = UILabel()
    private lazy var primaryValueView = UILabel()
    private lazy var primaryValueButton = MacaroonUIKit.Button()
    private lazy var secondaryValueAndSelectedPointView = UIStackView()
    private lazy var secondaryValueView = UILabel()
    private lazy var selectedPointDateValueView = Label()
    
    private var chartData: ChartViewData?
    private lazy var chartViewModel = ChartViewModel(dataModel: ChartDataModel())
    private lazy var chartHostingController = UIHostingController(rootView: makeChartView())
    
    private var theme = ASAProfileViewTheme()
    
    private let shouldShowCharts: Bool
    
    // MARK: - Initialisers
    
    @MainActor init(shouldShowCharts: Bool) {
        self.shouldShowCharts = shouldShowCharts
        super.init(frame: .zero)
        setupGestures()
        if shouldShowCharts {
            setupViewModelCallback()
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeChartView() -> ChartView {
        ChartView(viewModel: chartViewModel)
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

        addExpandedContent(theme)
        expand()
    }

    func bindData(_ viewModel: ASAProfileViewModel?) {
        bindIcon(viewModel)

        nameView.bindData(viewModel?.name)

        if let titleSeparator = viewModel?.titleSeparator {
            titleSeparator.load(in: titleSeparatorView)
        } else {
            titleSeparatorView.text = nil
            titleSeparatorView.attributedText = nil
        }

        if let id = viewModel?.id {
            id.load(in: idView)
        } else {
            idView.text = nil
            idView.attributedText = nil
        }

        if let primaryValue = viewModel?.primaryValue {
            primaryValue.load(in: primaryValueView)
        } else {
            primaryValueView.text = nil
            primaryValueView.attributedText = nil
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
    
    func updateChart(with data: ChartViewData) {
        chartData = data
        chartViewModel.refresh(with: data.model)
        chartHostingController.rootView = makeChartView()
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

        let isSaved = saveContentSizesIfNeeded()
        if isSaved {
            uiInteractions[.layoutChanged]?.publish()
        }
    }
}

extension ASAProfileView {
    func expand() {
        compressedContentView.axis = .vertical
        compressedContentView.alignment = .leading
        compressedContentView.distribution = .fill
        compressedContentView.spacing = theme.expandedSpacingBetweenIconAndTitle

        iconView.snp.updateConstraints {
            $0.fitToSize(theme.expandedIconSize)
        }

        primaryValueView.alpha = 1

        secondaryValueView.alpha = 1
        
        selectedPointDateValueView.alpha = 1
        
        chartHostingController.view.alpha = 1
    }

    func compress() {
        compressedContentView.axis = .horizontal
        compressedContentView.alignment = .center
        compressedContentView.distribution = .equalCentering
        compressedContentView.spacing = theme.compressedSpacingBetweenIconAndTitle

        iconView.snp.updateConstraints {
            $0.fitToSize(theme.compressedIconSize)
        }

        primaryValueView.alpha = 0

        secondaryValueView.alpha = 0
        
        selectedPointDateValueView.alpha = 0
        
        chartHostingController.view.alpha = 0
    }
}

extension ASAProfileView {
    private func addExpandedContent(_ theme: ASAProfileViewTheme) {
        addSubview(expandedContentView)
        expandedContentView.alignment = .leading
        expandedContentView.distribution = .fill
        expandedContentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addCompressedContent(theme)
        addPrimaryValue(theme)
        addSecondaryValueAndSelectPointDate(theme)
        
        if shouldShowCharts {
            addChartView(theme)
        }
    }

    private func addCompressedContent(_ theme: ASAProfileViewTheme) {
        expandedContentView.addArrangedSubview(compressedContentView)

        addIcon(theme)
        addTitle(theme)
    }

    private func addIcon(_ theme: ASAProfileViewTheme) {
        iconView.build(theme.icon)

        compressedContentView.addArrangedSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.expandedIconSize)
        }
    }

    private func addTitle(_ theme: ASAProfileViewTheme) {
        compressedContentView.addArrangedSubview(titleView)
        
        titleView.snp.makeConstraints {
            $0.height.equalTo(theme.titleViewHeight)
        }

        addName(theme)
        addTitleSeparator(theme)
        addID(theme)
    }

    private func addName(_ theme: ASAProfileViewTheme) {
        nameView.customize(theme.name)

        titleView.addSubview(nameView)
        nameView.fitToVerticalIntrinsicSize()
        nameView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addTitleSeparator(_ theme: ASAProfileViewTheme) {
        titleSeparatorView.customizeAppearance(theme.titleSeparator)

        titleView.addSubview(titleSeparatorView)
        titleSeparatorView.fitToIntrinsicSize()
        titleSeparatorView.snp.makeConstraints {
            $0.leading == nameView.snp.trailing
            $0.centerY == 0
        }
    }

    private func addID(_ theme: ASAProfileViewTheme) {
        idView.customizeAppearance(theme.id)

        titleView.addSubview(idView)
        idView.fitToIntrinsicSize()
        idView.snp.makeConstraints {
            $0.top == 0
            $0.leading == titleSeparatorView.snp.trailing
            $0.bottom == 0
            $0.trailing == 0
        }

        startPublishing(
            event: .copyAssetID,
            for: idView
        )
    }

    private func addPrimaryValue(_ theme: ASAProfileViewTheme) {
        primaryValueView.customizeAppearance(theme.primaryValue)
        primaryValueView.addSubview(primaryValueButton)

        expandedContentView.addArrangedSubview(primaryValueView)
        primaryValueView.fitToVerticalIntrinsicSize()
        expandedContentView.setCustomSpacing(
            theme.spacingBetweenTitleAndPrimaryValue,
            after: compressedContentView
        )
        
        primaryValueButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addSecondaryValueAndSelectPointDate(_ theme: ASAProfileViewTheme) {
        secondaryValueAndSelectedPointView.alignment = .center
        secondaryValueAndSelectedPointView.distribution = .equalSpacing
        
        secondaryValueView.customizeAppearance(theme.secondaryValue)
        selectedPointDateValueView.customizeAppearance(theme.secondaryValue)
        
        [secondaryValueView, selectedPointDateValueView].forEach {
            secondaryValueAndSelectedPointView.addArrangedSubview($0)
        }

        expandedContentView.addArrangedSubview(secondaryValueAndSelectedPointView)
        
        secondaryValueAndSelectedPointView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        secondaryValueAndSelectedPointView.fitToVerticalIntrinsicSize()
        expandedContentView.setCustomSpacing(
            theme.spacingBetweenPrimaryValueAndSecondValue,
            after: primaryValueView
        )
    }
    
    private func addChartView(_ theme: ASAProfileViewTheme) {
        expandedContentView.addArrangedSubview(chartHostingController.view)
        
        chartHostingController.view.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.chartViewLeadingOffset)
            $0.trailing.equalToSuperview().offset(theme.chartViewTrailingOffset)
            $0.height.equalTo(theme.chartViewHeight)
        }
        
        chartHostingController.view.fitToVerticalIntrinsicSize()
        expandedContentView.setCustomSpacing(
            theme.spacingBetweenPrimaryValueAndSecondValue,
            after: secondaryValueAndSelectedPointView
        )
        
        expandedContentView.layoutIfNeeded()
    }
}

extension ASAProfileView {
    private func saveContentSizesIfNeeded() -> Bool {
        var isSaved = false

        let newExpandedContentSize = calculateExpandedContentSize()
        if intrinsicExpandedContentSize != newExpandedContentSize {
            intrinsicExpandedContentSize = newExpandedContentSize
            isSaved = true
        }

        let newCompressedContentSize = calculateCompressedContentSize()
        if intrinsicCompressedContentSize != newCompressedContentSize {
            intrinsicCompressedContentSize = newCompressedContentSize
            isSaved = true
        }

        return isSaved
    }

    private func calculateExpandedContentSize() -> CGSize {
        let width = bounds.width
        let iconSize = CGSize(theme.expandedIconSize)
        let titleSize = titleView.bounds.size
        let primaryValueSize = primaryValueView.bounds.size
        let secondaryValueSize = secondaryValueView.bounds.size
        let chartViewSize = chartHostingController.view.bounds.size
        let preferredHeight =
            iconSize.height +
            theme.expandedSpacingBetweenIconAndTitle +
            titleSize.height +
            theme.spacingBetweenTitleAndPrimaryValue +
            primaryValueSize.height +
            theme.spacingBetweenPrimaryValueAndSecondValue +
            secondaryValueSize.height +
            theme.spacingBetweenPrimaryValueAndSecondValue +
            chartViewSize.height
        /// <warning>
        /// The bounds of subviews can be zero when it is called for the first time.
        let height = max(preferredHeight, bounds.height)
        return CGSize(width: width, height: height)
    }

    private func calculateCompressedContentSize() -> CGSize {
        let width = bounds.width
        let iconSize = CGSize(theme.compressedIconSize)
        let titleSize = titleView.bounds.size
        let height = max(iconSize.height, titleSize.height)
        return CGSize(width: width, height: height)
    }
}

extension ASAProfileView {
    enum Event {
        case layoutChanged
        case copyAssetID
        case onAmountTap
    }
}
