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

//   RecordAccountDetailScreenEvent.swift

import Foundation
import MacaroonVendors

struct RecordAccountDetailScreenEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension RecordAccountDetailScreenEvent {
    enum `Type` {
        case tapAssets
        case tapAssetInbox
        case tapCollectibles
        case tapHistory
        case tapMore
        case tapSend
        case tapTransactionFilter
        case tapTransactionDownload
        case addAssets
        case manageAssets
        case tapBuyAlgo
        case tapSwap
        case tapChart

        var rawValue: ALGAnalyticsEventName {
            switch self {
            case .tapAssets:
                return .tapAssetsInAccountDetail
            case .tapAssetInbox:
                return .tapAssetInboxInAccountDetail
            case .tapCollectibles:
                return .tapCollectiblesInAccountDetail
            case .tapHistory:
                return .tapHistoryInAccountDetail
            case .tapMore:
                return .tapMoreInAccountDetail
            case .tapSend:
                return .tapSendInAccountDetail
            case .tapTransactionFilter:
                return .tapFilterTransactionInHistory
            case .tapTransactionDownload:
                return .tapDownloadTransactionInHistory
            case .addAssets:
                return .addAsset
            case .manageAssets:
                return .manageAsset
            case .tapBuyAlgo:
                return .tapBuyAlgoInAccountDetail
            case .tapSwap:
                return .tapSwapInAccountDetail
            case .tapChart:
                return .tapChartInAccountDetail
            }
        }
    }
}

extension AnalyticsEvent where Self == RecordAccountDetailScreenEvent {
    static func recordAccountDetailScreen(
        type: RecordAccountDetailScreenEvent.`Type`
    ) -> Self {
        return RecordAccountDetailScreenEvent(type: type)
    }
}
