//
//  Account.swift
//  algorand
//
//  Created by Omer Emre Aslan on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum AccountStatus: String, Model {
    case offline = "Offline"
    case online = "Online"
    case notParticipating = "NotParticipating"
}

extension AccountStatus: Encodable {
}

class Account: Model {
    let address: String
    var amount: UInt64
    var status: AccountStatus
    var rewards: UInt64?
    var pendingRewards: UInt64?
    var participation: Participation?
    var totalAssets: [String: AssetDetail]?
    var assets: [String: Asset]?
    
    var assetDetails: [AssetDetail]?
    var name: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        address = try container.decode(String.self, forKey: .address)
        amount = try container.decode(UInt64.self, forKey: .amount)
        status = try container.decode(AccountStatus.self, forKey: .status)
        rewards = try container.decodeIfPresent(UInt64.self, forKey: .rewards)
        pendingRewards = try container.decodeIfPresent(UInt64.self, forKey: .pendingRewards)
        participation = try container.decodeIfPresent(Participation.self, forKey: .participation)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        if let totalAssets = try? container.decodeIfPresent([String: AssetDetail].self, forKey: .totalAssets) {
            self.totalAssets = totalAssets
            assetDetails = totalAssets.map { key, value -> AssetDetail in
                value.index = key
                return value
            }
        }
        assets = try? container.decodeIfPresent([String: Asset].self, forKey: .assets) ?? nil
    }
    
    init(address: String) {
        self.address = address
        amount = 0
        status = .offline
        rewards = 0
        pendingRewards = 0
        participation = nil
        totalAssets = nil
        assets = nil
    }
    
    func update(withAccount account: Account) {
        amount = account.amount
        status = account.status
        rewards = account.rewards
        pendingRewards = account.pendingRewards
        participation = account.participation
        totalAssets = account.totalAssets
        assets = account.assets
        
        if let updatedName = account.name {
            name = updatedName
        }
    }
    
    func mnemonics() -> [String] {
        return UIApplication.shared.appConfiguration?.session.mnemonics(forAccount: self.address) ?? []
    }
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    func doesAccountHasParticipationKey() -> Bool {
        return !(participation == nil || participation?.partpkb64 == defaultParticipationKey)
    }

    func isThereAnyDifferentAsset() -> Bool {
        return totalAssets != nil || assets != nil
    }
}

extension Account {
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case amount = "amount"
        case status = "status"
        case rewards = "rewards"
        case pendingRewards = "pendingrewards"
        case name = "name"
        case participation = "participation"
        case totalAssets = "thisassettotal"
        case assets = "assets"
        case assetDetails = "assetDetails"
    }
}

extension Account: Encodable {
}

// MARK: - Equatable
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
