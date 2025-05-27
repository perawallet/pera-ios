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

//   SUIChartView.swift

import SwiftUI
import Charts

struct DataPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

let mockData: [DataPoint] = (1...10).map { i in
    DataPoint(day: "Day \(i)", value: Double.random(in: 10...100))
}

struct SUIChartView: View {
    var body: some View {
        LineChartView(data: mockData)
    }
}

#Preview {
    SUIChartView()
}

struct LineChartView: View {
    let data: [DataPoint]
    let lineColor = Color(red: 31/255, green: 142/255, blue: 157/255)
    let gradientColor = Color(red: 40/255, green: 167/255, blue: 155/255)
    let interpolationMethod: InterpolationMethod = .monotone

    var body: some View {
        let maxValue = data.map(\.value).max() ?? 100

        Chart(data) { point in
            LineMark(
                x: .value("Day", point.day),
                y: .value("Value", point.value)
            )
            .foregroundStyle(lineColor)
            .interpolationMethod(interpolationMethod)

            AreaMark(
                x: .value("Day", point.day),
                y: .value("Value", point.value)
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
