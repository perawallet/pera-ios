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
//   AccountHandle.swift


import Foundation
import MagpieCore
import MagpieHipo

struct AccountHandle {
    var isUpToDate: Bool {
        switch status {
        case .upToDate,
             .loadingAssetDetails,
             .refreshingAssetDetails,
             .failedAssetDetails,
             .expiredAssetDetails,
             .ready:
            return true
        default:
            return false
        }
    }
    var isReady: Bool {
        return status == .ready
    }
    
    let value: Account
    let status: Status
    
    init(
        localAccount: AccountInformation,
        status: Status
    ) {
        self.init(
            account: Account(localAccount: localAccount),
            status: status
        )
    }
    
    init(
        account: Account,
        status: Status
    ) {
        self.value = account
        self.status = status
    }
}

extension AccountHandle {
    func canRefresh() -> Bool {
        switch status {
        case .refreshing,
             .expired,
             .upToDate,
             .loadingAssetDetails,
             .refreshingAssetDetails,
             .failedAssetDetails,
             .expiredAssetDetails,
             .ready:
            return true
        default:
            return false
        }
    }
    
    func canRefreshAssetDetails() -> Bool {
        switch status {
        case .refreshingAssetDetails,
             .expiredAssetDetails,
             .ready:
            return true
        default:
            return false
        }
    }
}

extension AccountHandle {
    enum Status: Hashable {
        case idle

        case loading
        case refreshing
        case failed(HIPNetworkError<NoAPIModel>)
        case expired(HIPNetworkError<NoAPIModel>) /// Update is failed
        case upToDate /// Account is fetched

        /// <warning>
        /// For below status for the asset details, the account must be `upToDate`.
        case loadingAssetDetails
        case refreshingAssetDetails
        case failedAssetDetails(HIPNetworkError<NoAPIModel>)
        case expiredAssetDetails(HIPNetworkError<NoAPIModel>) /// Update is failed

        case ready /// Account and its asset details are fetched
    }
}
