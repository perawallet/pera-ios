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

//   RecordMenuScreenEvent.swift

import Foundation
import MacaroonVendors

public struct RecordMenuScreenEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension RecordMenuScreenEvent {
    public enum `Type` {
        case tapQRScan
        case tapSettings
        case tapCreateCard
        case tapGoToCards
        case tapNfts
        case tapTransfer
        case tapBuyAlgo
        case tapReceive
        case tapStake
        case tapInviteFriends
        case tapCloseInviteFriends
        case tapShareInviteFriends

        public var rawValue: ALGAnalyticsEventName {
            switch self {
            case .tapQRScan:
                return .tapQRInMenu
            case .tapSettings:
                return .tapBarPressedSettingsEvent
            case .tapCreateCard:
                return .tapCreateCardInMenu
            case .tapGoToCards:
                return .tapGoToCardsInMenu
            case .tapNfts:
                return .tapNftsInMenu
            case .tapTransfer:
                return .tapTransferInMenu
            case .tapBuyAlgo:
                return .tapBuyAlgoInMenu
            case .tapReceive:
                return .tapReceiveInMenu
            case .tapStake:
                return .tapStakeInMenu
            case .tapInviteFriends:
                return .tapInviteFriendsInMenu
            case .tapCloseInviteFriends:
                return .tapCloseInviteFriendsInMenu
            case .tapShareInviteFriends:
                return .tapShareInviteFriendsInMenu
            }
        }
    }
}

extension AnalyticsEvent where Self == RecordMenuScreenEvent {
    public static func recordMenuScreen(
        type: RecordMenuScreenEvent.`Type`
    ) -> Self {
        return RecordMenuScreenEvent(type: type)
    }
}
