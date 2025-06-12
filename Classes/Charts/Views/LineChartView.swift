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

    @State private var selectedPoint: ChartDataPoint?

    private let chartLineColor = Color("Chart/chartLine")
    private let borderColor = Color("Defaults/bg")
    private let gradientColor = Color("Chart/chartGradient")
    private let selectedPointLineColor = Color("Text/grayLighter")
    private let interpolationMethod: InterpolationMethod = .monotone

    var body: some View {
        let maxValue = data.map(\.value).max() ?? 100

        GeometryReader { geo in
            let chart = Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value("Day", point.day),
                        y: .value("Amount", point.value)
                    )
                    .foregroundStyle(chartLineColor)
                    .interpolationMethod(interpolationMethod)

                    AreaMark(
                        x: .value("Day", point.day),
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

                if let selected = selectedPoint {
                    RuleMark(x: .value("Day", selected.day))
                        .foregroundStyle(selectedPointLineColor)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))

                    PointMark(
                        x: .value("Day", selected.day),
                        y: .value("Amount", selected.value)
                    )
                    .symbol {
                        Circle()
                            .strokeBorder(borderColor, lineWidth: 2)
                            .background(Circle().fill(chartLineColor))
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
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let origin = geo[proxy.plotAreaFrame].origin
                                    let location = value.location
                                    let xPosition = location.x - origin.x
                                    let yPosition = location.y - origin.y

                                    guard let day: Int = proxy.value(atX: xPosition) else {
                                        selectedPoint = nil
                                        print("---Reset")
                                        return
                                    }

                                    guard let nearest = data.min(by: { abs($0.day - day) < abs($1.day - day) }) else {
                                        selectedPoint = nil
                                        print("---Reset")
                                        return
                                    }

                                    if let xPos = proxy.position(forX: nearest.day),
                                       let yPos = proxy.position(forY: nearest.value) {
                                        let pointPosition = CGPoint(x: xPos, y: yPos)
                                        let verticalTolerance: CGFloat = 20
                                        if abs(pointPosition.y - yPosition) <= verticalTolerance {
                                            selectedPoint = nearest
                                            print("---Day: \(nearest.day), Value: \(nearest.value)")
                                        } else {
                                            selectedPoint = nil
                                            print("---Reset")
                                        }
                                    } else {
                                        selectedPoint = nil
                                        print("---Reset")
                                    }
                                }
                        )
                }
            }
            overlay
                .padding(.trailing, 16)
        }
    }
}
