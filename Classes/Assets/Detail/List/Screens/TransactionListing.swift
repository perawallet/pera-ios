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
//   TransactionListing.swift

import MacaroonUIKit
import UIKit

protocol TransactionListing {
    var type: TransactionTypeFilter { get }
    var account: Account { get }
    var assetDetail: AssetDetail? { get }
    var infoViewConfiguration: TransactionInfoConfiguration? { get }
}

extension TransactionListing {
    var assetDetail: AssetDetail? {
        nil
    }

    var infoViewConfiguration: TransactionInfoConfiguration? {
        nil
    }
}

struct TransactionInfoConfiguration {
    let infoViewSize: LayoutSize?
    let cellType: UICollectionViewCell.Type
}

struct AlgoTransactionListing: TransactionListing {
    var type: TransactionTypeFilter {
        return .algos
    }

    var account: Account

    var infoViewConfiguration: TransactionInfoConfiguration? {
        TransactionInfoConfiguration(
            infoViewSize: (UIScreen.main.bounds.width, 255 + 32),
            cellType: AlgosDetailInfoViewCell.self
        )
    }
}

struct AssetTransactionListing: TransactionListing {
    var type: TransactionTypeFilter {
        return .asset(assetDetail.id)
    }

    var account: Account
    var assetDetail: AssetDetail

    var infoViewConfiguration: TransactionInfoConfiguration? {
        TransactionInfoConfiguration(
            infoViewSize: (UIScreen.main.bounds.width, 251 + 32),
            cellType: AssetDetailInfoViewCell.self
        )
    }
}

struct AccountTransactionListing: TransactionListing {
    var type: TransactionTypeFilter {
        return .all
    }

    var account: Account
}

enum TransactionTypeFilter {
    case algos
    case asset(AssetID)
    case all
}
