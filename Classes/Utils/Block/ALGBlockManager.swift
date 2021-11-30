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
//   ALGBlockManager.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class ALGBlockManager: ALGBlockManaging {
    private let api: ALGAPI
    private var waitForNextRoundRequest: EndpointOperatable?
    private var transactionParamsRequest: EndpointOperatable?

    private(set) var currentRound: UInt64?
    private(set) var params: TransactionParams?

    lazy var handlers = Handlers()

    init(
        api: ALGAPI
    ) {
        self.api = api
    }

    func waitForNextRoundOnBlock(
        _ round: BlockRound?
    ) {
        if let nextRound = round {
            waitForNextRoundRequest = api.waitRound(WaitRoundDraft(round: nextRound)) { [weak self] roundDetailResponse in
                guard let self = self else {
                    return
                }

                switch roundDetailResponse {
                case let .success(result):
                    self.currentRound = result.lastRound
                    self.handlers.didReceiveNextRound?(result.lastRound)
                case .failure:
                    /// Needs to get the transaction params for the latest round and try again
                    asyncBackground(qos: .userInitiated) { [weak self] in
                        guard let self = self else {
                            return
                        }

                        self.getTransactionParamsAndWaitForTheNextRoundOnBlock()
                    }
                }
            }
        } else {
            asyncBackground(qos: .userInitiated) { [weak self] in
                guard let self = self else {
                    return
                }

                self.getTransactionParamsAndWaitForTheNextRoundOnBlock()
            }
        }
    }

    func cancelAllRequest() {
        waitForNextRoundRequest?.cancel()
        transactionParamsRequest?.cancel()
    }
}

extension ALGBlockManager {
    private func getTransactionParamsAndWaitForTheNextRoundOnBlock() {
        transactionParamsRequest = api.getTransactionParams { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(params):
                self.params = params
                self.currentRound = params.lastRound
            case .failure:
                /// Needs to get the last round from round 0 and try again,
                asyncBackground(qos: .userInitiated) { [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.waitForNextRoundOnBlock(0)
                }
            }

            guard let round = self.currentRound else {
                return
            }

            asyncBackground(qos: .userInitiated) { [weak self] in
                guard let self = self else {
                    return
                }

                self.waitForNextRoundOnBlock(round)
            }
        }
    }
}

extension ALGBlockManager {
    struct Handlers {
        var didReceiveNextRound: ((BlockRound) -> Void)?
    }
}

protocol ALGBlockManaging {
    func waitForNextRoundOnBlock(
        _ round: BlockRound?
    )
    func cancelAllRequest()
}

typealias BlockRound = UInt64
