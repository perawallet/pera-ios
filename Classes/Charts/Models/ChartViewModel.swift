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

//   ChartViewModel.swift

import Combine

class ChartViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var data: [ChartDataPointViewModel] = []
    @Published var selectedPeriod: ChartDataPeriod = .oneWeek
    @Published var selectedPoint: ChartDataPointViewModel?
    
    var onSelectedPeriodChanged: ((ChartDataPeriod) -> Void)?
    var onPointSelected: ((ChartDataPointViewModel?) -> Void)?

    private var dataModel: ChartDataModel
    private var cancellables = Set<AnyCancellable>()

    init(dataModel: ChartDataModel) {
        self.dataModel = dataModel
        setupBindings()
    }
    
    private func setupBindings() {
        dataModel.$data
            .assign(to: &$data)

        dataModel.$isLoading
            .assign(to: &$isLoading)

        dataModel.$period
            .removeDuplicates()
            .sink { [weak self] period in
                guard let self else { return }
                if selectedPeriod != period {
                    selectedPeriod = period
                }
            }
            .store(in: &cancellables)

        $selectedPeriod
            .removeDuplicates()
            .sink { [weak self] newPeriod in
                guard let self else { return }
                if dataModel.period != newPeriod {
                    isLoading = true
                    dataModel.period = newPeriod
                    onSelectedPeriodChanged?(newPeriod)
                }
            }
            .store(in: &cancellables)
        
        $selectedPoint
            .removeDuplicates()
            .sink { [weak self] point in
                guard let self else { return }
                onPointSelected?(point)
            }
            .store(in: &cancellables)
    }
    
    func refresh(with newDataModel: ChartDataModel) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        dataModel = newDataModel
        setupBindings()
    }
}
