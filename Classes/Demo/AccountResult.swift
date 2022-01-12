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
//   AccountResult.swift


import Foundation

enum AccountResult {
    case idle(AccountInformation)
    case loading(AccountInformation)
    case fault(AccountInformation)
    case refreshing(Account)
    case expired(Account) /// Refreshing failed
    case loadingAssets(Account)
    case faultAssets(Account)
    case refreshingAssets(Account)
    case expiredAssets(Account) /// Refreshing failed
    case ready(Account)
}

extension AccountResult {
    var address: String {
        switch self {
        case .idle(let account),
             .loading(let account),
             .fault(let account):
            return account.address
        case .refreshing(let accountDetail),
             .expired(let accountDetail),
             .loadingAssets(let accountDetail),
             .faultAssets(let accountDetail),
             .refreshingAssets(let accountDetail),
             .expiredAssets(let accountDetail),
             .ready(let accountDetail):
            return accountDetail.address
        }
    }
}
