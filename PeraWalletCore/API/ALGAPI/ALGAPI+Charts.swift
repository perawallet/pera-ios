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

//   ALGAPI+Charts.swift

import MagpieCore

public enum ChartDataPeriod: String, Hashable, Equatable, CaseIterable {
    case oneWeek = "one-week"
    case oneMonth = "one-month"
    case oneYear = "one-year"
    
    public var title: String {
        switch self {
        case .oneWeek: return String(localized: "chart-segcontrol-week")
        case .oneMonth: return String(localized: "chart-segcontrol-month")
        case .oneYear: return String(localized: "chart-segcontrol-year")
        }
    }
    
    public static func == (lhs: ChartDataPeriod, rhs: ChartDataPeriod) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        rawValue.hash(into: &hasher)
    }
}

extension ALGAPI {
    @discardableResult
    public func fetchAssetBalanceChartData(
        address: String,
        assetId: String,
        period: ChartDataPeriod,
        currency: String,
        onCompleted handler: @escaping (Response.ModelResult<AssetChartDataResultDTO>) -> Void
    ) -> EndpointOperatable {
        EndpointBuilder(api: self)
            .base(.mobileV2(network))
            .path(.assetBalanceChartData, args: address, assetId)
            .query(AssetBalanceChartDataDraft(period: period, currency: currency))
            .method(.get)
            .completionHandler(handler)
            .execute()
    }
}

extension ALGAPI {
    @discardableResult
    public func fetchAddressWealthBalanceChartData(
        address: String,
        period: ChartDataPeriod,
        currency: String,
        ordering: String? = nil,
        onCompleted handler: @escaping (Response.ModelResult<ChartDataResultDTO>) -> Void
    ) -> EndpointOperatable {
        EndpointBuilder(api: self)
            .base(.mobileV2(network))
            .path(.addressWealthBalanceChartData, args: address)
            .query(AddressWealthBalanceChartDataDraft(period: period, currency: currency, ordering: ordering))
            .method(.get)
            .completionHandler(handler)
            .execute()
    }
}

extension ALGAPI {
    @discardableResult
    public func fetchWalletWealthBalanceChartData(
        addresses: [String],
        period: ChartDataPeriod,
        currency: String,
        ordering: String? = nil,
        onCompleted handler: @escaping (Response.ModelResult<ChartDataResultDTO>) -> Void
    ) -> EndpointOperatable {
        EndpointBuilder(api: self)
            .base(.mobileV2(network))
            .path(.walletWealthBalanceChartData)
            .method(.post)
            .body(WalletWealthBalanceChartDataDraft(accountAddresses: addresses, period: period, currency: currency))
            .completionHandler(handler)
            .execute()
    }
}
