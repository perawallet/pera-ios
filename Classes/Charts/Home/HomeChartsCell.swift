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

final class HomeChartsCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let theme = HomeChartsViewTheme()
    var onChange: ((ChartDataPeriod) -> Void)?
    
    private let dataModel = ChartDataModel()
    private lazy var chartViewModel = ChartViewModel(dataModel: dataModel)
    private lazy var observer = SelectedPeriodObserver(selected: .oneWeek)
    
    private lazy var hostingController = UIHostingController(rootView: makeChartView())
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addChartView(Self.theme)
        setupObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeChartView() -> ChartView {
        ChartView(viewModel: chartViewModel, observer: observer)
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
    
    private func setupObserver() {
        observer.onChange = { [weak self] newSelected in
            guard let self = self else { return }
            if newSelected != self.dataModel.period {
                self.dataModel.isLoading = true
            }
            self.onChange?(newSelected)
        }
    }
    
    func bindData(_ data: ChartViewData) {
        dataModel.data = data.chartValues
        dataModel.isLoading = false
        dataModel.period = data.period
        observer.selected = data.period

        hostingController.rootView = makeChartView()
    }
}
