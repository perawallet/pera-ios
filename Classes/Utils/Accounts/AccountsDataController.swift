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
//   AccountsDataController.swift

import Foundation
import MacaroonUtils

final class AccountsDataController: AccountsDataControlling {
    private let api: ALGAPI

    lazy var handlers = Handlers()

    private lazy var blockDataController = ALGBlockDataController(api: api)
    private lazy var currencyFether = CurrencyFetcher(api: api)
    private var currencyRepeater: Repeater?

    private let currencyRepeaterIntervalInSeconds: TimeInterval = 60.0

    private(set) var accountsDataState = AccountsDataState(accountsState: .loading, assetsState: .loading, currencyState: .loading)

    init(
        api: ALGAPI
    ) {
        self.api = api
    }

    func fetchData() {
        fetchRepeatedBlockInformation()
        fetchRepeatedCurrencyInformation()
    }

    func retry() {
        cancelAllRequests()
        fetchData()
    }

    func cancelAllRequests() {
        blockDataController.cancelAllRequests()

        currencyFether.cancelCurrencyDetailRequest()
        currencyRepeater = nil
        currencyRepeater?.invalidate()
    }
}

extension AccountsDataController {
    private func fetchRepeatedBlockInformation() {
        blockDataController.handlers.didReceiveNextRound = { [weak self] round in
            guard let self = self else {
                return
            }

            self.handlers.didReceiveNextRound?(round)
        }

        blockDataController.handlers.didFetchAccounts = { [weak self] accounts in
            guard let self = self else {
                return
            }

            self.accountsDataState.accountsState = .finished(accounts: accounts)
            self.handlers.currentDataState?(self.accountsDataState)
        }

        blockDataController.handlers.didFetchAssets = { [weak self] assets in
            guard let self = self else {
                return
            }

            self.accountsDataState.assetsState = .finished(assets: assets)
            self.handlers.currentDataState?(self.accountsDataState)
        }

        blockDataController.handlers.didFailFetchingAccounts = { [weak self] error in
            guard let self = self else {
                return
            }

            self.accountsDataState.accountsState = .failed(error: error)
            self.handlers.currentDataState?(self.accountsDataState)
        }

        blockDataController.handlers.didFailFetchingAssets = { [weak self] error in
            guard let self = self else {
                return
            }

            self.accountsDataState.assetsState = .failed(error: error)
            self.handlers.currentDataState?(self.accountsDataState)
        }

        blockDataController.getAccountInformationsOnEachBlock()
    }

    private func fetchRepeatedCurrencyInformation() {
        currencyFether.handlers.didFetchCurrencyDetails = { [weak self] currencyDetails in
            guard let self = self else {
                return
            }

            self.accountsDataState.currencyState = .finished(currency: currencyDetails)
            self.handlers.currentDataState?(self.accountsDataState)
        }

        currencyFether.handlers.didFailFetchingCurrencyDetails = { [weak self] error in
            guard let self = self else {
                return
            }

            self.accountsDataState.currencyState = .failed(error: error)
            self.handlers.currentDataState?(self.accountsDataState)
        }

        currencyRepeater = Repeater(intervalInSeconds: currencyRepeaterIntervalInSeconds) {  [weak self] in
            guard let self = self else {
                return
            }

            self.currencyFether.getPreferredCurrencyDetails()
        }

        currencyRepeater?.resume()
    }
}

extension AccountsDataController {
    struct Handlers {
        var currentDataState: ((AccountsDataState) -> Void)?
        var didReceiveNextRound: ((BlockRound) -> Void)?
    }
}

protocol AccountsDataControlling {
    var accountsDataState: AccountsDataState { get }

    func fetchData()
    func retry()
    func cancelAllRequests()
}
