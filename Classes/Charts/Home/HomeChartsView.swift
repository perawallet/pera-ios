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
import Combine

final class HomeChartsView:
    UIView,
    ViewComposable,
    ListReusable {
    
    class ChartDataModel: ObservableObject {
        @Published var isLoading: Bool = true
        @Published var data: [ChartDataPoint] = []
    }
    private let chartDataModel = ChartDataModel()
    private lazy var observer = SelectedPeriodObserver(selected: .oneWeek)
    
    private var chartView: ChartView {
        ChartView(dataModel: chartDataModel, observer: observer)
    }
    
    var onChange: ((ChartDataPeriod) -> Void)?
    
    
    private lazy var hostingController = UIHostingController(rootView: chartView)
    
    private var cancellables = Set<AnyCancellable>()
    
    private var currentData: [ChartDataPoint] = []
    private var currentLoading: Bool = true
    
    // MARK: - Setups

    func customize(_ theme: HomeChartsViewTheme) {
        addBackground(theme)
        addChartView(theme)
        observer.onChange = { [weak self] newSelected in
//            self?.chartDataModel.isLoading = true
            self?.onChange?(newSelected)
        }
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: ChartViewModel) {
        print("---bindData called with \(viewModel.chartValues.count) points, period: \(viewModel.period)")
        print("---bindData called on thread:", Thread.isMainThread)
        DispatchQueue.main.async {
            self.chartDataModel.data = viewModel.chartValues
            self.chartDataModel.isLoading = false
            self.observer.selected = viewModel.period
        }
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
            $0.height.equalToSuperview()
        }
    }
}
