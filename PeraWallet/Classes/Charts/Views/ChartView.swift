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
import pera_wallet_core

struct ChartView: View {
    @ObservedObject var viewModel: ChartViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ZStack {
                    Color.Defaults.bg
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .offset(y: -20)
                }
            } else {
                VStack {
                    LineChartView(data: viewModel.data, selectedPoint: $viewModel.selectedPoint)
                    ChartSegmentedControlView(selected: $viewModel.selectedPeriod)
                }
            }
        }
        .background(Color.Defaults.bg)
    }
}
