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

//   ChartView.swift

import SwiftUI
import Charts

struct ChartDataPoint: Identifiable, Hashable, Equatable {
    let id = UUID()
    let day: Int
    let value: Double
}

class ChartDataModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var period: ChartDataPeriod = .oneWeek
    @Published var data: [ChartDataPoint] = []
}

class SelectedPeriodObserver: ObservableObject {
    @Published var selected: ChartDataPeriod {
        didSet {
            onChange?(selected)
        }
    }
    var onChange: ((ChartDataPeriod) -> Void)?
    init(selected: ChartDataPeriod) { self.selected = selected }
}

struct ChartView: View {
    @ObservedObject var dataModel: ChartDataModel
    @ObservedObject var observer: SelectedPeriodObserver
    
    var body: some View {
        Group {
            if dataModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                VStack {
                    LineChartView(data: dataModel.data)
                    ChartSegmentedControlView(selected: $observer.selected)
                }
            }
        }
        .background(Color("Defaults/bg"))
    }
}

