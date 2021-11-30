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
//  Account.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class Account: ALGEntityModel {
    let address: String
    var amount: UInt64
    var amountWithoutRewards: UInt64
    var rewardsBase: UInt64?
    var round: UInt64?
    var signatureType: SignatureType?
    var status: AccountStatus
    var rewards: UInt64?
    var pendingRewards: UInt64
    var participation: Participation?
    var createdAssets: [AssetDetail]?
    var assets: [Asset]?
    var authAddress: String?
    var createdRound: UInt64?
    var closedRound: UInt64?
    var isDeleted: Bool?

    var appsLocalState: [ApplicationLocalState]?
    var appsTotalExtraPages: Int?
    var appsTotalSchema: ApplicationStateSchema?
    var createdApps: [AlgorandApplication]?
    
    var assetDetails: [AssetDetail] = []
    /// <todo>
    /// Will be changed with assetDetails after the transition to the new api is completed.
    var assetInformations: [AssetInformation] = []
    
    var name: String?
    var type: AccountType = .standard
    var ledgerDetail: LedgerDetail?
    var receivesNotification: Bool
    var rekeyDetail: RekeyDetail?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        address = apiModel.address
        amount = apiModel.amount
        amountWithoutRewards = apiModel.amountWithoutPendingRewards
        rewardsBase = apiModel.rewardBase
        round = apiModel.round
        signatureType = apiModel.sigType
        status = apiModel.status
        rewards = apiModel.rewards
        pendingRewards = apiModel.pendingRewards
        participation = apiModel.participation
        createdAssets = apiModel.createdAssets.unwrapMap(AssetDetail.init)
        assets = apiModel.assets
        authAddress = apiModel.authAddr
        createdRound = apiModel.createdAtRound
        closedRound = apiModel.closedAtRound
        isDeleted = apiModel.deleted
        appsLocalState = apiModel.appsLocalState
        appsTotalExtraPages = apiModel.appsTotalExtraPages
        appsTotalSchema = apiModel.appsTotalSchema
        createdApps = apiModel.createdApps
        receivesNotification = true
    }

    init(
        address: String,
        type: AccountType,
        ledgerDetail: LedgerDetail? = nil,
        name: String? = nil,
        rekeyDetail: RekeyDetail? = nil,
        receivesNotification: Bool = true
    ) {
        self.address = address
        amount = 0
        amountWithoutRewards = 0
        pendingRewards = 0
        status = .offline
        self.name = name
        self.type = type
        self.ledgerDetail = ledgerDetail
        self.receivesNotification = receivesNotification
        self.rekeyDetail = rekeyDetail
    }
    
    init(accountInformation: AccountInformation) {
        self.address = accountInformation.address
        self.amount = 0
        self.amountWithoutRewards = 0
        self.pendingRewards = 0
        self.status = .offline
        self.name = accountInformation.name
        self.type = accountInformation.type
        self.ledgerDetail = accountInformation.ledgerDetail
        self.receivesNotification = accountInformation.receivesNotification
        self.rekeyDetail = accountInformation.rekeyDetail
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.address = address
        apiModel.amount = amount
        apiModel.amountWithoutPendingRewards = amountWithoutRewards
        apiModel.createdAtRound = rewardsBase
        apiModel.sigType = signatureType
        apiModel.status = status
        apiModel.pendingRewards = pendingRewards
        apiModel.participation = participation
        apiModel.createdAssets = createdAssets?.encode()
        apiModel.assets = assets
        apiModel.authAddr = authAddress
        apiModel.closedAtRound = closedRound
        apiModel.deleted = isDeleted
        apiModel.appsLocalState = appsLocalState
        apiModel.appsTotalExtraPages = appsTotalExtraPages
        apiModel.appsTotalSchema = appsTotalSchema
        apiModel.createdApps = createdApps
        return apiModel
    }
}

extension Account {
    struct APIModel: ALGAPIModel {
        var address: String
        var amount: UInt64
        var status: AccountStatus
        var rewards:  UInt64?
        var amountWithoutPendingRewards: UInt64
        var pendingRewards: UInt64
        var rewardBase: UInt64?
        var participation: Participation?
        var createdAssets: [AssetDetail.APIModel]?
        var assets: [Asset]?
        var sigType: SignatureType?
        var round: UInt64?
        var authAddr: String?
        var createdAtRound: UInt64?
        var closedAtRound: UInt64?
        var deleted: Bool?
        var appsLocalState: [ApplicationLocalState]?
        var appsTotalExtraPages: Int?
        var appsTotalSchema: ApplicationStateSchema?
        var createdApps: [AlgorandApplication]?

        init() {
            self.address = ""
            self.amount = 0
            self.status = .offline
            self.rewards = nil
            self.amountWithoutPendingRewards = 0
            self.pendingRewards = 0
            self.rewardBase = nil
            self.participation = nil
            self.createdAssets = nil
            self.assets = nil
            self.sigType = nil
            self.round = nil
            self.authAddr = nil
            self.createdAtRound = nil
            self.closedAtRound = nil
            self.deleted = nil
            self.appsLocalState = nil
            self.appsTotalExtraPages = nil
            self.appsTotalSchema = nil
            self.createdApps = nil
        }

        private enum CodingKeys: String, CodingKey {
            case address
            case amount
            case status
            case rewards
            case amountWithoutPendingRewards = "amount-without-pending-rewards"
            case pendingRewards = "pending-rewards"
            case rewardBase = "reward-base"
            case participation
            case createdAssets = "created-assets"
            case assets
            case sigType = "sig-type"
            case round
            case authAddr = "auth-addr"
            case createdAtRound = "created-at-round"
            case closedAtRound = "closed-at-round"
            case deleted
            case appsLocalState = "apps-local-state"
            case appsTotalExtraPages = "apps-total-extra-pages"
            case appsTotalSchema = "apps-total-schema"
            case createdApps = "created-apps"
        }
    }
}

extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.address == rhs.address
    }
}

extension Account: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(address.hashValue)
    }
}
