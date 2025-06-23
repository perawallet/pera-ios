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

//   LineChartView.swift

import SwiftUI
import Charts

struct LineChartView: View {
    let data: [ChartDataPoint]
    
    private let xAxisLabel = "Date"
    private let yAxisLabel = "Value"
    private let lineColor = Color.Chart.line
    private let gradientColor = Color.Chart.gradient
    private let interpolationMethod: InterpolationMethod = .monotone

    var body: some View {
        let maxValue = data.map(\.value).max() ?? 100

        Chart(data) { point in
            LineMark(
                x: .value(xAxisLabel, point.day),
                y: .value(yAxisLabel, point.value)
            )
            .foregroundStyle(lineColor)
            .interpolationMethod(interpolationMethod)

            AreaMark(
                x: .value(xAxisLabel, point.day),
                y: .value(yAxisLabel, point.value)
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
