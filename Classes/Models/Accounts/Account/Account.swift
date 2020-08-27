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
    }
    
    init(address: String, type: AccountType = .standard, ledgerDetail: LedgerDetail? = nil, name: String? = nil) {
        self.address = address
        amount = 0
        status = .offline
        self.name = name
        self.type = type
        self.ledgerDetail = ledgerDetail
    }
}

extension Account {
    func update(with account: Account) {
        amount = account.amount
        status = account.status
        rewards = account.rewards
        pendingRewards = account.pendingRewards
        participation = account.participation
        createdAssets = account.createdAssets
        assets = account.assets
        assetDetails = account.assetDetails
        type = account.type
        ledgerDetail = account.ledgerDetail
        amountWithoutRewards = account.amountWithoutRewards
        rewardsBase = account.rewardsBase
        round = account.round
        signatureType = account.signatureType
        authAddress = account.authAddress
        
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
        return !(participation == nil || participation?.voteParticipationKey == defaultParticipationKey)
    }

    func isThereAnyDifferentAsset() -> Bool {
        return assets != nil
    }
    
    func areAssetsDifferent(than account: Account) -> Bool {
        return assets != account.assets || !assetDetails.containsSameElements(as: account.assetDetails)
    }
    
    func amount(for assetDetail: AssetDetail) -> Double? {
        guard let asset = assets?.first(where: { $0.id == assetDetail.id }) else {
            return nil
        }
        return asset.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)
    }
    
    func amountDisplayWithFraction(for assetDetail: AssetDetail) -> String? {
        return amount(for: assetDetail)?.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
    }
    
    func removeAsset(_ id: Int64?) {
        assetDetails.removeAll { assetDetail -> Bool in
            assetDetail.id == id
        }
    }
    
    func containsAsset(_ id: Int64) -> Bool {
        return assetDetails.contains { assetDetail -> Bool in
            assetDetail.id == id
        }
    }
    
    func hasAuthAccount() -> Bool {
        return authAddress != nil
    }
    
    func isLedger() -> Bool {
        return type == .ledger
    }
    
    func isRekeyed() -> Bool {
        return type == .rekeyed || hasAuthAccount()
    }
    
    func requiresLedgerConnection() -> Bool {
        return isLedger() || isRekeyed()
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
    }
}

extension Account: Encodable { }

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

extension Account {
    enum SignatureType: String, Model {
        case sig = "sig"
        case multiSig = "msig"
        case logicSig = "lsig"
    }
}

extension Account.SignatureType: Encodable { }

class AccountResponse: Model {
    let account: Account
    let currentRound: Int64
}

extension AccountResponse {
    enum CodingKeys: String, CodingKey {
        case account = "account"
        case currentRound = "current-round"
    }
}
