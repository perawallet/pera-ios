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
//   BlockListener.swift


import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class BlockListener {
    typealias Handler = () -> Void
    
    private var lastRound: BlockRound?
    private var handler: Handler?
    
    private var ongoingEndpointToFetchTransactionParams: EndpointOperatable?
    private var ongoingEndpointToWaitForNextBlock: EndpointOperatable?

    private let api: ALGAPI

    init(
        api: ALGAPI
    ) {
        self.api = api
    }
}

extension BlockListener {
    func start(
        onReceive handler: @escaping Handler
    ) {
        self.handler = handler
        
        if let lastRound = lastRound {
            watchNextBlock(after: lastRound)
        } else {
            watchNextBlock()
        }
    }

    func stop() {
        handler = nil
        
        ongoingEndpointToFetchTransactionParams?.cancel()
        ongoingEndpointToFetchTransactionParams = nil

        ongoingEndpointToWaitForNextBlock?.cancel()
        ongoingEndpointToWaitForNextBlock = nil
    }
}

extension BlockListener {
    private func watchNextBlock() {
        self.fetchTransactionParams { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let round):
                self.watchNextBlock(after: round)
            case .failure:
                self.watchNextBlock(after: 0)
            }
        }
    }
    
    private func watchNextBlock(
        after round: BlockRound
    ) {
        waitForNextBlock(after: round) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let roundDetail):
                let lastRound = roundDetail.lastRound
                
                self.lastRound = lastRound
                self.handler?()
                
                self.watchNextBlock(after: lastRound)
            case .failure:
                self.watchNextBlock()
            }
        }
    }
}

extension BlockListener {
    private typealias FetchTransactionParamsCompletionHandler = (Result<BlockRound, HIPNetworkError<NoAPIModel>>) -> Void
    
    private func fetchTransactionParams(
        onCompletion handler: @escaping FetchTransactionParamsCompletionHandler
    ) {
        ongoingEndpointToFetchTransactionParams =
            api.getTransactionParams { [weak self] result in
                guard let self = self else { return }
            
                self.ongoingEndpointToFetchTransactionParams = nil
            
                switch result {
                case .success(let params):
                    handler(.success(params.lastRound))
                case .failure(let apiError, let apiErrorDetail):
                    let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    handler(.failure(error))
                }
            }
    }
}

extension BlockListener {
    private typealias WaitForNextBlockCompletionHandler = (Result<RoundDetail, HIPNetworkError<NoAPIModel>>) -> Void
    
    private func waitForNextBlock(
        after round: BlockRound,
        onCompletion handler: @escaping WaitForNextBlockCompletionHandler
    ) {
        let draft = WaitRoundDraft(round: round)
        
        ongoingEndpointToWaitForNextBlock =
            api.waitRound(draft) { [weak self] result in
                guard let self = self else { return }
                
                self.ongoingEndpointToWaitForNextBlock = nil
                
                switch result {
                case .success(let roundDetail):
                    handler(.success(roundDetail))
                case .failure(let apiError, let apiErrorDetail):
                    let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    handler(.failure(error))
                }
            }
    }
}
