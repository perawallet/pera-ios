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
//   ALGBlockDataController.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class ALGBlockDataController: ALGBlockDataControlling {
    private let api: ALGAPI

    lazy var handlers = Handlers()

    private lazy var blockManager = ALGBlockManager(api: api)
    private lazy var accountInformationController = AccountInformationController(api: api)

    init(
        api: ALGAPI
    ) {
        self.api = api
    }

    func getAccountInformationsOnEachBlock() {
        startWaitingNextRoundOnBlock()
    }

    func cancelAllRequests() {
        blockManager.cancelAllRequest()
        accountInformationController.cancelAllRequests()
    }
}

extension ALGBlockDataController {
    private func startWaitingNextRoundOnBlock(after latestRound: BlockRound? = nil) {
        blockManager.handlers.didReceiveNextRound = { [weak self] round in
            guard let self = self else {
                return
            }

            self.fetchAccountInformations()

            self.handlers.didReceiveNextRound?(round)
            self.startWaitingNextRoundOnBlock(after: round)
        }

        asyncBackground(qos: .userInitiated) { [weak self] in
            guard let self = self else {
                return
            }

            self.blockManager.waitForNextRoundOnBlock(latestRound)
        }
    }

    private func fetchAccountInformations() {
        accountInformationController.handlers.didFetchAccounts = { [weak self] accounts in
            guard let self = self else {
                return
            }

            self.handlers.didFetchAccounts?(accounts)
        }

        accountInformationController.handlers.didFetchAssets = { [weak self] assets in
            guard let self = self else {
                return
            }

            self.handlers.didFetchAssets?(assets)
        }

        accountInformationController.handlers.didFailFetchingAccounts = { [weak self] error in
            guard let self = self else {
                return
            }

            self.handlers.didFailFetchingAccounts?(error)
        }

        accountInformationController.handlers.didFailFetchingAssets = { [weak self] error in
            guard let self = self else {
                return
            }

            self.handlers.didFailFetchingAssets?(error)
        }

        accountInformationController.startFetchingAccountInformations()
    }
}

extension ALGBlockDataController {
    struct Handlers {
        var didReceiveNextRound: ((BlockRound) -> Void)?
        var didFetchAccounts: (([Account]) -> Void)?
        var didFetchAssets: (([AssetInformation]) -> Void)?
        var didFailFetchingAccounts: ((APIError) -> Void)?
        var didFailFetchingAssets: ((APIError) -> Void)?
    }
}

protocol ALGBlockDataControlling {
    func getAccountInformationsOnEachBlock()
    func cancelAllRequests()
}
