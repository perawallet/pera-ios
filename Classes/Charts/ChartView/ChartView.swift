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
    @ObservedObject var dataModel: HomeChartsView.ChartDataModel
    @ObservedObject var observer: SelectedPeriodObserver
    
    var body: some View {
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
}

struct LineChartView: View {
    let data: [ChartDataPoint]
    private let lineColor = Color("Chart/chartLine")
    private let gradientColor = Color("Chart/chartGradient")
    private let interpolationMethod: InterpolationMethod = .monotone

    var body: some View {
        let maxValue = data.map(\.value).max() ?? 100

        Chart(data) { point in
            LineMark(
                x: .value("Date", point.day),
                y: .value("Amount", point.value)
            )
            .foregroundStyle(lineColor)
            .interpolationMethod(interpolationMethod)

            AreaMark(
                x: .value("Date", point.day),
                y: .value("Amount", point.value)
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [
                        gradientColor.opacity(0.15),
                        gradientColor.opacity(0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(interpolationMethod)
        }
        .chartYScale(domain: 0...(maxValue + 10))
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.clear)
                .padding(.horizontal, -20)
        }
        .padding(.trailing, 16)
    }
}
