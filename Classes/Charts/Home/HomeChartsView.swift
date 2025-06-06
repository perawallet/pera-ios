// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   HomeChartsView.swift

import MacaroonUIKit
import UIKit
import SwiftUI

final class HomeChartsView:
    UIView,
    ViewComposable,
    UIInteractable,
    ListReusable {
    
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .weekChartSelected: TargetActionInteraction(),
        .monthChartSelected: TargetActionInteraction(),
        .yearChartSelected: TargetActionInteraction()
    ]
    
    private var isLoading = false {
        didSet {
            updateChart()
        }
    }
    
    private lazy var hostingController: UIHostingController<SUIChartView> = UIHostingController(rootView: chartView)
    private lazy var chartView: SUIChartView = SUIChartView(isLoading: true, chartData: [])
    private lazy var segmentedControl = ChartSegmentedControl()
    
    // MARK: - Setups

    func customize(_ theme: HomeChartsViewTheme) {
        addBackground(theme)
        addChartView(theme)
        addSegmentedControl(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: ChartViewModel) {
        segmentedControl.selectedSegment = viewModel.period
        isLoading = false
        updateChart(with: viewModel.chartValues)
    }
    
    private func updateChart(with data: [ChartDataPoint] = []) {
        hostingController.rootView = SUIChartView(isLoading: isLoading, chartData: data)
    }
    
    override func didMoveToWindow() {
        segmentedControl.selectedSegment = .oneWeek
        isLoading = true
    }
    
    private func addBackground(_ theme: HomeChartsViewTheme) {
        customizeAppearance(theme.background)
    }
    
    private func addChartView(_ theme: HomeChartsViewTheme) {
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview().inset(-2)
            $0.top.equalToSuperview()
            $0.height.equalTo(136)
        }
    }
    
    private func addSegmentedControl(_ theme: HomeChartsViewTheme) {
        addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top == hostingController.view.snp.bottom + theme.spacingBetweenChartAndSegControl
            $0.trailing.equalToSuperview().inset(92)
            $0.leading.equalToSuperview().inset(92)
            $0.bottom.equalToSuperview()
        }
        
        segmentedControl.selectionChanged = { [weak self] _ in
            guard let self = self else { return }
            isLoading = true
        }
        
        for (index, button) in segmentedControl.buttons.enumerated() {
            let event: Event
            switch ChartDataPeriod.allCases[index] {
            case .oneWeek: event = .weekChartSelected
            case .oneMonth: event = .monthChartSelected
            case .oneYear: event = .yearChartSelected
            }
            startPublishing(event: event, for: button)
        }
    }
}

extension HomeChartsView {
    enum Event {
        case weekChartSelected
        case monthChartSelected
        case yearChartSelected
    }
}
