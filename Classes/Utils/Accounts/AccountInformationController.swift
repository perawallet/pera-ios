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
//   AccountInformationController.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AccountInformationController: AccountInformationControlling {
    private let api: ALGAPI

    private lazy var accountFetcher = AccountFetcher(api: api)
    private lazy var assetFetcher = AssetFetcher(api: api)

    private var accounts: [Account] = []

    lazy var handlers = Handlers()

    init(
        api: ALGAPI
    ) {
        self.api = api
    }

    func startFetchingAccountInformations() {
        fetchAccountInformations()
    }

    func retry() {
        cancelAllRequests()
        startFetchingAccountInformations()
    }

    func cancelAllRequests() {
        accountFetcher.cancelAccountDetailRequests()
        assetFetcher.cancelAssetInformationRequest()
    }
}

extension AccountInformationController {
    private func fetchAccountInformations() {
        accountFetcher.handlers.didFetchAccounts = { [weak self] accounts in
            guard let self = self else {
                return
            }

            self.accounts = accounts
            self.handlers.didFetchAccounts?(accounts)

            let sessionAccounts = self.api.session.accounts

            asyncBackground(qos: .userInitiated) { [weak self] in
                guard let self = self else {
                    return
                }

                /// Update the accounts and notify for changes if there's any change on an account
                if self.hasChangesOnAccounts() {
                    self.updateAccountsOnSession()
                    self.handlers.hasChangesOnAccounts?(true)
                }

                /// Fetch and update the assets if there's any change related to the assets of an account
                if self.hasDifferentAssetInformations(from: sessionAccounts) {
                    let assetIDs = self.getAssetIDs(from: accounts)
                    self.fetchAssetInformations(assetIDs)
                }
            }
        }

        accountFetcher.handlers.didFailFetchingAccount = { [weak self] error in
            guard let self = self else {
                return
            }

            self.handlers.didFailFetchingAccounts?(error)
        }

        accountFetcher.getAccountDetails()
    }

    private func hasChangesOnAccounts() -> Bool {
        for account in accounts {
            guard let currentAccount = api.session.accounts.first(matching: (\.address, account.address)),
                  account.hasDifference(with: currentAccount) else {
                      continue
            }

            return true
        }

        return false
    }

    private func updateAccountsOnSession() {
        api.session.accounts = accounts
    }

    private func hasDifferentAssetInformations(
        from sessionAccounts: [Account]
    ) -> Bool {
        for account in accounts {
            if let accountFromSession = sessionAccounts.first(matching: (\.address, account.address)),
               account.containsDifferentAssets(than: accountFromSession) {
                return true
            }
        }

        return false
    }

    private func getAssetIDs(
        from accounts: [Account]
    ) -> [AssetID] {
        var assetIDs: Set<AssetID> = []

        accounts.forEach { account in
            guard let accountAssets = account.assets else {
                return
            }

            assetIDs.formUnion(accountAssets.map { $0.id })
        }

        return Array(assetIDs)
    }

    private func fetchAssetInformations(
        _ ids: [AssetID]
    ) {
        assetFetcher.handlers.didFetchAssetInformations = { [weak self] assetInformations in
            guard let self = self else {
                return
            }

            asyncBackground(qos: .userInitiated) { [weak self] in
                guard let self = self else {
                    return
                }

                self.updateAccountInformations(with: assetInformations)

                self.handlers.didFetchAssets?(assetInformations)
                self.handlers.didFetchAccountInformations?(self.accounts, assetInformations)
            }
        }

        assetFetcher.handlers.didFailFetchingAssetInformations = { [weak self] error in
            guard let self = self else {
                return
            }

            self.handlers.didFailFetchingAssets?(error)
        }

        assetFetcher.getAssetsByIDs(ids)
    }

    private func updateAccountInformations(
        with assetInformations: [AssetInformation]
    ) {
        for account in accounts where !account.assets.isNilOrEmpty {
            guard let assets = account.assets else {
                continue
            }

            var assetInformations = [AssetInformation]()

            /// Set assetInformation list of an account with the latest result
            for asset in assets {
                guard let assetInformation = assetInformations.first(matching: (\.id, asset.id)) else {
                    continue
                }

                assetInformations.append(assetInformation)
            }

            account.assetInformations = assetInformations
        }

        updateAccountsOnSession()
    }
}

extension AccountInformationController {
    struct Handlers {
        var didFetchAccountInformations: (([Account], [AssetInformation]) -> Void)?
        var didFetchAccounts: (([Account]) -> Void)?
        var didFetchAssets: (([AssetInformation]) -> Void)?
        var hasChangesOnAccounts: ((Bool) -> Void)?
        var didFailFetchingAccounts: ((APIError) -> Void)?
        var didFailFetchingAssets: ((APIError) -> Void)?
    }
}

protocol AccountInformationControlling {
    func startFetchingAccountInformations()
    func retry()
    func cancelAllRequests()
}
