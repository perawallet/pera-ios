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

//   ChartViewModel.swift

import Combine

class ChartViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var data: [ChartDataPoint] = []
    @Published var selectedPeriod: ChartDataPeriod = .oneWeek

    private var dataModel: ChartDataModel
    private var cancellables = Set<AnyCancellable>()

    init(dataModel: ChartDataModel) {
        self.dataModel = dataModel

        // Forward data and loading from dataModel
        dataModel.$data
            .assign(to: &$data)

        dataModel.$isLoading
            .assign(to: &$isLoading)

        dataModel.$period
            .removeDuplicates()
            .sink { [weak self] period in
                guard let self = self else { return }
                if self.selectedPeriod != period {
                    self.selectedPeriod = period
                }
            }
            .store(in: &cancellables)

        $selectedPeriod
            .removeDuplicates()
            .sink { [weak self] period in
                guard let self = self else { return }
                if self.dataModel.period != period {
                    self.dataModel.period = period
                }
            }
            .store(in: &cancellables)
    }
}
