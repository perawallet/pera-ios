//
//  Account+Helpers.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

extension Account {
    func mnemonics() -> [String] {
        return UIApplication.shared.appConfiguration?.session.mnemonics(forAccount: self.address) ?? []
    }
}

extension Account {
    func amount(for assetDetail: AssetDetail) -> Double? {
        guard let asset = assets?.first(where: { $0.id == assetDetail.id }) else {
            return nil
        }
        return asset.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)
    }
    
    func amountDisplayWithFraction(for assetDetail: AssetDetail) -> String? {
        return amount(for: assetDetail)?.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
    }
}

extension Account {
    func doesAccountHasParticipationKey() -> Bool {
        return !(participation == nil || participation?.voteParticipationKey == defaultParticipationKey)
    }

    func isThereAnyDifferentAsset() -> Bool {
        return assets != nil
    }
    
    func hasDifferentAssets(than account: Account) -> Bool {
        return assets != account.assets || !assetDetails.containsSameElements(as: account.assetDetails)
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
}

extension Account {
    func hasAuthAccount() -> Bool {
        return authAddress != nil
    }
    
    func isWatchAccount() -> Bool {
        return type == .watch
    }
    
    func isLedger() -> Bool {
        if isWatchAccount() {
            return false
        }
        
        if let authAddress = authAddress {
            return address == authAddress
        }
        
        return type == .ledger
    }
    
    func isRekeyed() -> Bool {
        if isWatchAccount() {
            return false
        }
        
        if let authAddress = authAddress {
            return authAddress != address
        }
        
        return false
    }
    
    func requiresLedgerConnection() -> Bool {
        return isLedger() || isRekeyed()
    }
    
    func addRekeyDetail(_ ledgerDetail: LedgerDetail, for address: String) {
        if rekeyDetail != nil {
            self.rekeyDetail?[address] = ledgerDetail
        } else {
            self.rekeyDetail = [address: ledgerDetail]
        }
    }

    var currentLedgerDetail: LedgerDetail? {
        if let authAddress = authAddress {
            return rekeyDetail?[authAddress]
        }
        return ledgerDetail
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
        rekeyDetail = account.rekeyDetail
        
        if let updatedName = account.name {
            name = updatedName
        }
    }
    
    func accountImage() -> UIImage? {
        if isWatchAccount() {
            return img("icon-account-type-watch")
        } else if isRekeyed() {
            return img("icon-account-type-rekeyed")
        } else if isLedger() {
            return img("img-ledger-small")
        } else {
            return img("icon-account-type-standard")
        }
    }
}
