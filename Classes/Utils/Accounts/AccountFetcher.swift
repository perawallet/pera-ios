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
//   AccountFetcher.swift

import Foundation
import MagpieCore

final class AccountFetcher: AccountFetching {
    private let api: ALGAPI
    private var accountDetailRequests: [PublicKey: EndpointOperatable?] = [:]

    lazy var handlers = Handlers()

    init(
        api: ALGAPI
    ) {
        self.api = api
    }

    func getAccountDetails() {
        guard let localAccounts = api.session.authenticatedUser?.accounts,
              !localAccounts.isEmpty else {
                  handlers.didFetchAccounts?([])
                  return
        }

        var fetchedAccounts = [Account]()

        for localAccount in localAccounts {
            let accountDetailRequest = api.fetchAccount(AccountFetchDraft(publicKey: localAccount.address)) { [weak self] response in
                guard let self = self else {
                    return
                }

                switch response {
                case .success(let accountWrapper):
                    let account = accountWrapper.account
                    account.assets = account.nonDeletedAssets()
                    account.update(from: localAccount) /// Update local fields of an account
                    fetchedAccounts.append(account)

                    if localAccounts.count == fetchedAccounts.count {
                        self.returnAllFetchedAccounts(fetchedAccounts)
                    }
                case let .failure(error, _):
                    /// Error 404 means that the account exists with 0 balance. So, it should be added to the account list of the user.
                    if error.isHttpNotFound {
                        let account = Account(accountInformation: localAccount)
                        account.update(from: localAccount)
                        fetchedAccounts.append(account)

                        if localAccounts.count == fetchedAccounts.count {
                            self.returnAllFetchedAccounts(fetchedAccounts)
                        }
                    } else {
                        self.handlers.didFailFetchingAccount?(error)
                    }
                }
            }

            accountDetailRequests[localAccount.address] = accountDetailRequest
        }
    }

    func cancelAccountDetailRequests() {
        accountDetailRequests.forEach { $0.value?.cancel() }
    }
}

extension AccountFetcher {
    private func returnAllFetchedAccounts(
        _ fetchedAccounts: [Account]
    ) {
        accountDetailRequests.removeAll()
        handlers.didFetchAccounts?(fetchedAccounts)
    }
}

extension AccountFetcher {
    struct Handlers {
        var didFetchAccounts: (([Account]) -> Void)?
        var didFailFetchingAccount: ((APIError) -> Void)?
    }
}

protocol AccountFetching {
    func getAccountDetails()
    func cancelAccountDetailRequests()
}
