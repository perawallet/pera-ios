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

//
//  Account+Helpers.swift

import Foundation
import UIKit
import MagpieCore
import MacaroonUtils

extension Account {
    public func isSameAccount(with otherAcc: Account) -> Bool {
        return isSameAccount(with: otherAcc.address)
    }

    public func isSameAccount(with address: String) -> Bool {
        return self.address == address
    }
}

extension Account {
    public func hasParticipationKey() -> Bool {
        return !(participation == nil || participation?.voteParticipationKey == defaultParticipationKey)
    }

    public func hasAnyAssets() -> Bool {
        return !assets.isNilOrEmpty
    }
    
    public func hasDifferentAssets(than account: Account) -> Bool {
        return
            !assets.someArray.containsSameElements(as: account.assets.someArray) ||
            !standardAssets.someArray.containsSameElements(as: account.standardAssets.someArray)
    }

    public func hasDifferentApps(than account: Account) -> Bool {
        return totalCreatedApps != account.totalCreatedApps || appsLocalState?.count != account.appsLocalState?.count
    }

    public var hasDifferentMinBalance: Bool {
        return hasAnyAssets() || isThereAnyCreatedApps || isThereAnyOptedApps || isThereSchemaValues || isThereAnyAppExtraPages
    }

    private var isThereAnyCreatedApps: Bool {
       return totalCreatedApps > 0
    }

    private var isThereAnyOptedApps: Bool {
        return !appsLocalState.isNilOrEmpty
    }

    private var isThereSchemaValues: Bool {
        guard let schema = appsTotalSchema else {
            return false
        }

        return schema.intValue.unwrap(or: 0) > 0 || schema.byteSliceCount.unwrap(or: 0) > 0
    }

    private var isThereAnyAppExtraPages: Bool {
        return appsTotalExtraPages.unwrap(or: 0) > 0
    }
}

extension Account {
    public var isCreated: Bool {
        return createdRound != nil
    }
    
    public var signerAddress: PublicKey {
        return authAddress ?? address
    }

    public var isRekeyedToSelf: Bool {
        return authAddress == address
    }

    public func hasAuthAccount() -> Bool {
        return authAddress != nil && !isRekeyedToSelf
    }
    
    public func hasLedgerDetail() -> Bool {
        return ledgerDetail != nil
    }
    
    public var hasJointAccountDetails: Bool { jointAccountParticipants != nil }
    
    public func requiresLedgerConnection() -> Bool {
        return authorization.isLedger || authorization.isRekeyedToLedger
    }
    
    public func addRekeyDetail(_ ledgerDetail: LedgerDetail, for address: String) {
        if rekeyDetail != nil {
            self.rekeyDetail?[address] = ledgerDetail
        } else {
            self.rekeyDetail = [address: ledgerDetail]
        }
    }

    public var currentLedgerDetail: LedgerDetail? {
        if let authAddress = authAddress {
            return rekeyDetail?[authAddress]
        }
        return ledgerDetail
    }

    /// <todo> This will be moved to a single place when the tickets on v5.4.2 is handled.
    public func calculateMinBalance() -> UInt64 {
        let assetCount = (assets?.count ?? 0) + 1
        let createdAppAmount = minimumTransactionMicroAlgosLimit * UInt64(totalCreatedApps)
        let localStateAmount = minimumTransactionMicroAlgosLimit * UInt64(appsLocalState?.count ?? 0)
        let totalSchemaValueAmount = totalNumIntConstantForMinimumAmount * UInt64(appsTotalSchema?.intValue ?? 0)
        let byteSliceAmount = byteSliceConstantForMinimumAmount * UInt64(appsTotalSchema?.byteSliceCount ?? 0)
        let extraPagesAmount = minimumTransactionMicroAlgosLimit * UInt64(appsTotalExtraPages ?? 0)

        let applicationRelatedMinimumAmount =
            createdAppAmount +
            localStateAmount +
            totalSchemaValueAmount +
            byteSliceAmount +
            extraPagesAmount

        let minBalance =
            (minimumTransactionMicroAlgosLimit * UInt64(assetCount)) +
            applicationRelatedMinimumAmount

        return minBalance
    }

    public func isOptedIn(to asset: AssetID) -> Bool {
        return self[asset] != nil || asset == algo.id
    }

    public func isOwner(of asset: AssetID) -> Bool {
        if let ownedAsset = self[asset] {
            return ownedAsset.amount > 0
        }

        return false
    }

    public func isCreator(of asset: Asset) -> Bool {
        return self.address == asset.creator?.address
    }
}

extension Account {
    public var typeTitle: String? {
        if authorization.isStandard {
            return nil
        }

        if authorization.isWatch {
            return String(localized: "title-watch-account").capitalized
        }

        if authorization.isLedger {
            return String(localized: "title-ledger-account").capitalized
        }

        if authorization.isRekeyed {
            return String(localized: "title-rekeyed-account").capitalized
        }

        if authorization.isNoAuth {
            return String(localized: "title-no-auth")
        }

        return nil
    }

    /// <note> `underlyingTypeImage` should be used when we want to display the underlying type instead of general types. For instance, the Standard to Ledger rekeyed account's general type is `standardToLedgerRekeyed`  but its underlying type is `standard`
    public var underlyingTypeImage: UIImage {
        if authorization.isStandard ||
           authorization.isStandardToStandardRekeyed ||
           authorization.isStandardToLedgerRekeyed ||
           authorization.isStandardToNoAuthInLocalRekeyed {
            if isHDAccount {
                return "icon-hd-account".uiImage
            }

            return "icon-standard-account".uiImage
        }

        if authorization.isLedger ||
           authorization.isLedgerToLedgerRekeyed ||
           authorization.isLedgerToStandardRekeyed ||
           authorization.isLedgerToNoAuthInLocalRekeyed {
            return "icon-ledger-account".uiImage
        }

        if authorization.isUnknown ||
           authorization.isUnknownToLedgerRekeyed ||
           authorization.isUnknownToStandardRekeyed ||
           authorization.isUnknownToNoAuthInLocalRekeyed {
            return "icon-unknown-account".uiImage
        }

        if authorization.isWatch {
            return "icon-watch-account".uiImage
        }

        return "icon-no-auth-account".uiImage
    }
    
    public var rawTypeImage: String {
        if authorization.isStandard {
            guard hdWalletAddressDetail != nil else {
                return "icon-standard-account"
            }
            return "icon-hd-account"
        }
        if authorization.isWatch {
            return "icon-watch-account"
        }
        if authorization == .jointAccount {
            return "icon-joint-account"
        }
        if authorization.isLedger {
            return "icon-ledger-account"
        }
        if authorization.isRekeyedToStandard {
            return "icon-any-to-standard-rekeyed-account"
        }
        if authorization.isRekeyedToLedger {
            return "icon-any-to-ledger-rekeyed-account"
        }
        if authorization.isNoAuth {
            return "icon-no-auth-account"
        }
        return "icon-unknown-account"
    }
    
    public var typeImage: UIImage { rawTypeImage.uiImage }
}
