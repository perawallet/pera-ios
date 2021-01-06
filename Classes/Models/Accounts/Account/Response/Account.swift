//
//  Account.swift
//  algorand
//
//  Created by Omer Emre Aslan on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class Account: Model {
    let address: String
    var amount: UInt64
    var amountWithoutRewards: UInt64?
    var rewardsBase: UInt64?
    var round: UInt64?
    var signatureType: SignatureType?
    var status: AccountStatus
    var rewards: UInt64?
    var pendingRewards: UInt64?
    var participation: Participation?
    var createdAssets: [AssetDetail]?
    var assets: [Asset]?
    var authAddress: String?
    
    var assetDetails: [AssetDetail] = []
    var name: String?
    var type: AccountType = .standard
    var ledgerDetail: LedgerDetail?
    var receivesNotification: Bool
    var rekeyDetail: RekeyDetail?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        address = try container.decode(String.self, forKey: .address)
        amount = try container.decode(UInt64.self, forKey: .amount)
        amountWithoutRewards = try container.decodeIfPresent(UInt64.self, forKey: .amountWithoutRewards)
        rewardsBase = try container.decodeIfPresent(UInt64.self, forKey: .rewardsBase)
        round = try container.decodeIfPresent(UInt64.self, forKey: .round)
        signatureType = try container.decodeIfPresent(SignatureType.self, forKey: .signatureType)
        status = try container.decode(AccountStatus.self, forKey: .status)
        rewards = try container.decodeIfPresent(UInt64.self, forKey: .rewards)
        pendingRewards = try container.decodeIfPresent(UInt64.self, forKey: .pendingRewards)
        participation = try container.decodeIfPresent(Participation.self, forKey: .participation)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        createdAssets = try? container.decodeIfPresent([AssetDetail].self, forKey: .createdAssets)
        assets = try? container.decodeIfPresent([Asset].self, forKey: .assets) ?? nil
        assetDetails = try container.decodeIfPresent([AssetDetail].self, forKey: .assetDetails) ?? []
        type = try container.decodeIfPresent(AccountType.self, forKey: .type) ?? .standard
        authAddress = try container.decodeIfPresent(String.self, forKey: .authAddress)
        ledgerDetail = try container.decodeIfPresent(LedgerDetail.self, forKey: .ledgerDetail)
        receivesNotification = try container.decodeIfPresent(Bool.self, forKey: .receivesNotification) ?? true
        rekeyDetail = try container.decodeIfPresent(RekeyDetail.self, forKey: .rekeyDetail)
    }
    
    init(address: String, type: AccountType, ledgerDetail: LedgerDetail? = nil, name: String? = nil, rekeyDetail: RekeyDetail? = nil, receivesNotification: Bool = true) {
        self.address = address
        amount = 0
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
        self.status = .offline
        self.name = accountInformation.name
        self.type = accountInformation.type
        self.ledgerDetail = accountInformation.ledgerDetail
        self.receivesNotification = accountInformation.receivesNotification
        self.rekeyDetail = accountInformation.rekeyDetail
    }
}

extension Account {
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case amount = "amount"
        case status = "status"
        case rewards = "rewards"
        case amountWithoutRewards = "amount-without-pending-rewards"
        case pendingRewards = "pending-rewards"
        case rewardsBase = "reward-base"
        case name = "name"
        case participation = "participation"
        case createdAssets = "created-assets"
        case assets = "assets"
        case assetDetails = "assetDetails"
        case type = "type"
        case ledgerDetail = "ledgerDetail"
        case signatureType = "sig-type"
        case round = "round"
        case authAddress = "auth-addr"
        case receivesNotification = "receivesNotification"
        case rekeyDetail = "rekeyDetail"
    }
}

extension Account: Encodable {
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
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
