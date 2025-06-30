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

//   LineChartOverlayView.swift

import SwiftUI
import Charts

struct LineChartOverlayView: View {
    let data: [ChartDataPoint]
    let proxy: ChartProxy
    let geo: GeometryProxy
    @Binding var selectedPoint: ChartDataPoint?
    
    var body: some View {
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
