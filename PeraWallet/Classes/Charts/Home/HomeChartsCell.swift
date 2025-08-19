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

//   HomeChartsCell.swift

import UIKit
import MacaroonUIKit
import SwiftUI
import Combine
import pera_wallet_core

final class HomeChartsCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let theme = HomeChartsViewTheme()
    var onPeriodChange: ((ChartDataPeriod) -> Void)?
    var onPointSelected: ((ChartDataPoint?) -> Void)?
    
    private var chartData: ChartViewData?
    private lazy var chartViewModel = ChartViewModel(dataModel: ChartDataModel())
    private lazy var hostingController = UIHostingController(rootView: makeChartView())
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addChartView(Self.theme)
        setupViewModelCallback()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeChartView() -> ChartView {
        ChartView(viewModel: chartViewModel)
    }
    
    private func addChartView(_ theme: HomeChartsViewTheme) {
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        
        hostingController.view.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.chartViewLeadingInset)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
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
    
    func bindData(_ data: ChartViewData) {
        self.chartData = data
        chartViewModel.refresh(with: data.model)
        hostingController.rootView = makeChartView()
    }
}
