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
    @Binding var selectedPoint: ChartDataPoint?
    
    private let xAxisLabel = "Date"
    private let yAxisLabel = "Value"
    
    var body: some View {
        let maxValue = data.map(\.primaryValue).max() ?? 100
        
        GeometryReader { geo in
            let chart = Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value(xAxisLabel, point.day),
                        y: .value(yAxisLabel, point.primaryValue)
                    )
                    .foregroundStyle(Color.Chart.line)
                    .interpolationMethod(.monotone)
                    
                    AreaMark(
                        x: .value(xAxisLabel, point.day),
                        yStart: .value(yAxisLabel, point.primaryValue),
                        yEnd: .value(yAxisLabel, -15)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                Color.Chart.gradient.opacity(0.15),
                                Color.Chart.gradient.opacity(0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.monotone)
                }
                
                if let selected = selectedPoint {
                    RuleMark(x: .value(xAxisLabel, selected.day))
                        .foregroundStyle(Color.Text.grayLighter)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    
                    PointMark(
                        x: .value(xAxisLabel, selected.day),
                        y: .value(yAxisLabel, selected.primaryValue)
                    )
                    .symbol {
                        Circle()
                            .strokeBorder(Color.Defaults.bg, lineWidth: 2)
                            .background(Circle().fill(Color.Chart.line))
                            .frame(width: 12, height: 12)
                    }
                }
            }
                .chartYScale(domain: -15...(maxValue + 10))
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(Color.clear)
                }
            
            chart
                .chartOverlay { proxy in
                    LineChartOverlayView(data: data, proxy: proxy, geo: geo, selectedPoint: $selectedPoint)
                }
                .padding(.trailing, 16)
        }
    }
}
