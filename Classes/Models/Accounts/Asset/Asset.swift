// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   Asset.swift

import Foundation

protocol Asset {
    /// Mimics ALGAsset in general so that it can be passed to different asset types as base.
    var id: AssetID { get }
    var amount: UInt64 { get }
    var isFrozen: Bool? { get }
    var isDeleted: Bool? { get }
    var optedInAtRound: UInt64? { get }
    var creator: AssetCreator? { get }
    var decimals: Int { get }

    /// <todo>
    /// Switch decimalAmount -> amount
    var decimalAmount: Decimal { get }

    var usdValue: Decimal? { get }
    var totalUSDValue: Decimal? { get }

    /// Asset management actions
    var state: AssetState { get set }

    /// Asset presentation
    var presentation: AssetPresentation { get }
    var amountWithFraction: Decimal { get }
}

enum AssetState: Codable {
    case ready
    case pending(AssetOperation)

    var isPending: Bool {
        switch self {
        case .ready:
            return false
        case .pending(let assetOperation):
            return assetOperation == .remove
        }
    }
}

enum AssetOperation: Codable {
    case remove
    case add
}

struct AssetPresentation {
    let id: AssetID
    let decimals: Int
    let name: String?
    let unitName: String?
    let isVerified: Bool
    let url: String?

    var displayNames: (primaryName: String, secondaryName: String?) {
        if let name = name,
           let code = unitName,
           !name.isEmptyOrBlank,
           !code.isEmptyOrBlank {
            return (name, "\(code.uppercased())")
        }

        if let name = name,
           !name.isEmptyOrBlank {
            return (name, nil)
        }

        if let code = unitName,
           !code.isEmptyOrBlank {
            return ("\(code.uppercased())", nil)
        }

        return ("title-unknown".localized, nil)
    }

    var hasOnlyAssetName: Bool {
        return !name.isNilOrEmpty && unitName.isNilOrEmpty
    }

    var hasOnlyUnitName: Bool {
        return name.isNilOrEmpty && !unitName.isNilOrEmpty
    }

    var hasBothDisplayName: Bool {
        return !name.isNilOrEmpty && !unitName.isNilOrEmpty
    }

    var hasDisplayName: Bool {
        return !name.isNilOrEmpty || !unitName.isNilOrEmpty
    }
}
