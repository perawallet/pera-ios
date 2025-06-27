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
    private let lineColor = Color.Chart.line
    private let gradientColor = Color.Chart.gradient
    private let selectedPointLineColor = Color.Text.grayLighter
    private let borderColor = Color.Defaults.bg
    private let interpolationMethod: InterpolationMethod = .monotone
    
    var body: some View {
        let maxValue = data.map(\.primaryValue).max() ?? 100
        
        GeometryReader { geo in
            let chart = Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value(xAxisLabel, point.day),
                        y: .value(yAxisLabel, point.primaryValue)
                    )
                    .foregroundStyle(lineColor)
                    .interpolationMethod(interpolationMethod)
                    
                    AreaMark(
                        x: .value(xAxisLabel, point.day),
                        y: .value(yAxisLabel, point.primaryValue)
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
                
                if let selected = selectedPoint {
                    RuleMark(x: .value(xAxisLabel, selected.day))
                        .foregroundStyle(selectedPointLineColor)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    
                    PointMark(
                        x: .value(xAxisLabel, selected.day),
                        y: .value(yAxisLabel, selected.primaryValue)
                    )
                    .symbol {
                        Circle()
                            .strokeBorder(borderColor, lineWidth: 2)
                            .background(Circle().fill(lineColor))
                            .frame(width: 12, height: 12)
                    }
                }
            }
                .chartYScale(domain: 0...(maxValue + 10))
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(Color.clear)
                }
            
            let overlay = chart.chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            LongPressGesture(minimumDuration: 0.1)
                                .sequenced(before: DragGesture(minimumDistance: 0))
                                .onChanged { value in
                                    switch value {
                                    case .second(true, let drag?):
                                        let origin = geo[proxy.plotAreaFrame].origin
                                        let plotWidth = geo[proxy.plotAreaFrame].width
                                        var xPosition = drag.location.x - origin.x
                                        xPosition = min(max(0, xPosition), plotWidth)
                                        
                                        guard let day: Int = proxy.value(atX: xPosition),
                                              let nearest = data.min(by: { abs($0.day - day) < abs($1.day - day) }) else {
                                            selectedPoint = nil
                                            return
                                        }
                                        selectedPoint = nearest
                                    default:
                                        break
                                    }
                                }
                                .onEnded { _ in
                                    selectedPoint = nil
                                }
                        )
                }
            }
            overlay
                .padding(.trailing, 16)
        }
    }
}
