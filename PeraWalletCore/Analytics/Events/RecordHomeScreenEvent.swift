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

//   RecordHomeScreenEvent.swift

import Foundation
import MacaroonVendors

public struct RecordHomeScreenEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension RecordHomeScreenEvent {
    public enum `Type` {
        case addAccount
        case assetInbox
        case qrScan
        case qrScanConnected
        case buyAlgo
        case send
        case fund
        case sort
        case stake
        case swap
        case tapAccounts
        case visitGovernance
        case visitRetail
        case visitStaking
        case visitCard
        case visitGeneric
        case notification
        case tapChart

        public var rawValue: ALGAnalyticsEventName {
            switch self {
            case .addAccount:
                return .createAccountInHomeScreen
            case .assetInbox:
                return .tapAssetInboxInHome
            case .qrScan:
                return .tapQRInHome
            case .qrScanConnected:
                return .qrConnectedInHome
            case .buyAlgo:
                return .tapBuyAlgoInHome
            case .send:
                return .tapSendInHome
            case .fund:
                return .tapFundInHome
            case .sort:
                return .tapSortInHome
            case .stake:
                return .tapStakeInHome
            case .swap:
                return .tapSwapInHome
            case .tapAccounts:
                return .createAccountInHomeScreen /// <todo>: It will be replaced the actual event when event created
            case .visitGovernance:
                return .tapGovernanceBanner
            case .visitRetail:
                return .tapRetailBanner
            case .visitStaking:
                return .tapStakingBanner
            case .visitCard:
                return .tapCardBanner
            case .visitGeneric:
                return .tapGenericBanner
            case .notification:
                return .tapNotifictionInHome
            case .tapChart:
                return .tapChartInHome
            }
        }
    }
}

extension AnalyticsEvent where Self == RecordHomeScreenEvent {
    public static func recordHomeScreen(
        type: RecordHomeScreenEvent.`Type`
    ) -> Self {
        return RecordHomeScreenEvent(type: type)
    }
}
