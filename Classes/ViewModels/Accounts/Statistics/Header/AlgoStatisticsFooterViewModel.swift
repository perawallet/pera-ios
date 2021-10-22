// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   StatisticsFooterViewModel.swift

import Foundation
import Macaroon

final class AlgoStatisticsFooterViewModel {
    private(set) var last24hVolumeViewModel: AlgoStatisticsInfoViewModel?
    private(set) var marketCapViewModel: AlgoStatisticsInfoViewModel?
    private(set) var previousCloseViewModel: AlgoStatisticsInfoViewModel?
    private(set) var openViewModel: AlgoStatisticsInfoViewModel?

    init(_ model: String) {
        /// <note>: Remove mock data
        last24hVolumeViewModel = AlgoStatisticsInfoViewModel(title: "algo-statistics-24h-volume".localized, value: "63,041,896")
        marketCapViewModel = AlgoStatisticsInfoViewModel(title: "algo-statistics-market-cap".localized, value: "2.581B")
        previousCloseViewModel = AlgoStatisticsInfoViewModel(title: "algo-statistics-previous-close".localized, value: "0.849725")
        openViewModel = AlgoStatisticsInfoViewModel(title: "algo-statistics-open".localized, value: "0.849725")
    }
}
