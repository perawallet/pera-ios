// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ChartViewData.swift
import pera_wallet_core

struct ChartViewData: Hashable, Equatable {
    let period: ChartDataPeriod
    let chartValues: [ChartDataPoint]
    let isLoading: Bool
    
    var model: ChartDataModel {
        let chartDataModel = ChartDataModel()
        chartDataModel.period = period
        chartDataModel.data = chartValues.map { ChartDataPointViewModel(value: $0.fiatValue, day: $0.day) }
        chartDataModel.isLoading = isLoading
        return chartDataModel
    }
}
