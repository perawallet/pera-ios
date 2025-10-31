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

//   ASADetailDataController.swift

import Foundation
import MagpieCore
import MagpieHipo
import pera_wallet_core

protocol ASADetailScreenDataController: AnyObject {
    typealias EventHandler = (ASADetailScreenDataControllerEvent) -> Void
    typealias Error = HIPNetworkError<NoAPIModel>

    var eventHandler: EventHandler? { get set }
    var configuration: ASADetailScreenConfiguration { get }

    var account: Account { get }
    var asset: Asset { get }

    func loadData()
    func fetchInitialChartData(address: String, assetId: String, period: ChartDataPeriod)
    func fetchInitialAssetPriceChartData(assetId: AssetID, period: ChartDataPeriod)
    func updateChartData(address: String, assetId: String, period: ChartDataPeriod)
    func updateAssetPriceChartData(assetId: AssetID, period: ChartDataPeriod)
}

enum ASADetailScreenDataControllerEvent {
    case willLoadData
    case didLoadData
    case didFailToLoadData(ASADiscoveryScreenDataController.Error)
    case didUpdateAccount(old: Account)
    case didFetchChartData(data: ChartViewData?, error: String?, period: ChartDataPeriod)
    case didFetchPriceChartData(data: ChartViewData?, error: String?, period: ChartDataPeriod)
}

struct ASADetailScreenConfiguration {
    let shouldDisplayAccountActionsBarButtonItem: Bool
    let shouldDisplayQuickActions: Bool
}

enum ASADetailScreenSection: Hashable {
    case profile
    case quickActions
    case marketInfo
    case pageContainer
}

enum ASADetailScreenItem: Hashable {
    case profile
    case quickActions
    case marketInfo
    case pageContainer
}
