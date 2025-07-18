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

//   ChartAPIDataController.swift

import Foundation

enum ChartDataScreen {
    case home
    case account(address: String)
    case asset(address: String, assetId: String)
}

final class ChartAPIDataController {
    var onFetch: ((String?, ChartDataPeriod, [ChartDataDTO]) -> Void)?
    var onAssetFetch: ((String?, ChartDataPeriod, [AssetChartDataDTO]) -> Void)?
    
    private let api: ALGAPI
    private let session: Session
    
    init(api: ALGAPI, session: Session) {
        self.api = api
        self.session = session
    }
    
    func loadData(screen: ChartDataScreen, period: ChartDataPeriod) {
        switch screen {
        case .home:
            loadHomeData(period: period)
        case .account(address: let address):
            loadAccountData(address: address, period: period)
        case .asset(address: let address, assetId: let assetId):
            loadAssetData(address: address, assetId: assetId, period: period)
        }
    }
    
    private func loadHomeData(period: ChartDataPeriod) {
        guard let addresses = session.authenticatedUser?.accounts.map({ $0.address }), addresses.isNonEmpty else {
            return
        }
        
        api.fetchWalletWealthBalanceChartData(addresses: addresses, period: period) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let values):
                onFetch?(nil, period, values.results.sorted(by: { $0.round < $1.round }))
            case .failure(let apiError, _):
                onFetch?(apiError.localizedDescription, period, [])
            }
        }
    }
    
    private func loadAccountData(address: String, period: ChartDataPeriod) {
        api.fetchAddressWealthBalanceChartData(address: address, period: period) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let values):
                onFetch?(nil, period, values.results.sorted(by: { $0.round < $1.round }))
            case .failure(let apiError, _):
                onFetch?(apiError.localizedDescription, period, [])
            }
        }
    }
    
    private func loadAssetData(address: String, assetId: String, period: ChartDataPeriod) {
        api.fetchAssetBalanceChartData(address: address, assetId: assetId, period: period) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let values):
                onAssetFetch?(nil, period, values.results)
            case .failure(let apiError, _):
                onAssetFetch?(apiError.localizedDescription, period, [])
            }
        }
    }
}
