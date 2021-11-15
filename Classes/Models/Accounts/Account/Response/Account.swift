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

final class Account: ALGResponseModel {
    var debugData: Data?
    
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
    var name: String?
    var type: AccountType = .standard
    var ledgerDetail: LedgerDetail?
    var receivesNotification: Bool
    var rekeyDetail: RekeyDetail?

    init(_ apiModel: APIModel = APIModel()) {
        address = apiModel.address
        amount = apiModel.amount
        amountWithoutRewards = apiModel.amountWithoutPendingRewards
        rewardsBase = apiModel.createdAtRound
        round = apiModel.createdAtRound
        signatureType = apiModel.sigType
        status = apiModel.status
        rewards = apiModel.createdAtRound
        pendingRewards = apiModel.pendingRewards
        participation = apiModel.participation.unwrap(Participation.init)
        createdAssets = apiModel.createdAssets.unwrapMap(AssetDetail.init)
        assets = apiModel.assets.unwrapMap(Asset.init)
        authAddress = apiModel.authAddr
        createdRound = apiModel.createdAtRound
        closedRound = apiModel.closedAtRound
        isDeleted = apiModel.deleted
        appsLocalState = apiModel.appsLocalState.unwrapMap(ApplicationLocalState.init)
        appsTotalExtraPages = apiModel.appsTotalExtraPages
        appsTotalSchema = apiModel.appsTotalSchema.unwrap(ApplicationStateSchema.init)
        createdApps = apiModel.createdApps.unwrapMap(AlgorandApplication.init)
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
}

extension Account {
    struct APIModel: ALGAPIModel {
        let address: String
        let amount: UInt64
        let status: AccountStatus
        let rewards:  UInt64?
        let amountWithoutPendingRewards: UInt64
        let pendingRewards: UInt64
        let rewardBase: UInt64?
        let participation: Participation.APIModel?
        let createdAssets: [AssetDetail.APIModel]?
        let assets: [Asset.APIModel]?
        let sigType: SignatureType?
        let round: UInt64?
        let authAddr: String?
        let createdAtRound: UInt64?
        let closedAtRound: UInt64?
        let deleted: Bool?
        let appsLocalState: [ApplicationLocalState.APIModel]?
        let appsTotalExtraPages: Int?
        let appsTotalSchema: ApplicationStateSchema.APIModel?
        let createdApps: [AlgorandApplication.APIModel]?

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
    }
}

//extension Account: Encodable {
//    func encoded() -> Data? {
//        return try? JSONEncoder().encode(self)
//    }
//}

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
