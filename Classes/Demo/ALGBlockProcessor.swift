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
//   ALGBlockProcessor.swift


import Foundation
import MagpieCore
import MagpieHipo

final class ALGBlockProcessor: BlockProcessor {
    typealias BlockRequest = () -> ALGBlockRequest
    
    private lazy var queue = ALGBlockOperationQueue()
    
    private var currentBlockRequest: ALGBlockRequest?
    private var blockEventQueue: DispatchQueue?
    private var blockEventHandler: BlockEventHandler?

    private let blockRequest: BlockRequest
    private let blockCycle: BlockCycle
    private let api: ALGAPI
    
    init(
        blockRequest: @escaping BlockRequest,
        blockCycle: BlockCycle,
        api: ALGAPI
    ) {
        self.blockRequest = blockRequest
        self.blockCycle = blockCycle
        self.api = api
    }
}

extension ALGBlockProcessor {
    func notify(
        queue: DispatchQueue,
        execute handler: @escaping BlockEventHandler
    ) {
        blockEventQueue = queue
        blockEventHandler = handler
    }

    func start() {
        blockCycle.startListening { [weak self] in
            guard let self = self else { return }
            
            if !self.canProceedOnBlock() {
                return
            }
            
            let newBlockRequest = self.blockRequest()
            self.proceed(with: newBlockRequest)
        }
    }
    
    func stop() {
        currentBlockRequest = nil
        
        blockCycle.stopListening()
        queue.cancelAllOperations()
    }
}

extension ALGBlockProcessor {
    private func canProceedOnBlock() -> Bool {
        return queue.isAvailable
    }
    
    private func proceed(
        with newBlockRequest: ALGBlockRequest
    ) {
        send(blockEvent: .willStart)
        
        currentBlockRequest = newBlockRequest
        currentBlockRequest?.localAccounts.forEach { localAccount in
            send(blockEvent: .willFetchAccount(address: localAccount.address))
            
            let accountFetchOperation =
                AccountDetailFetchOperation(input: .init(localAccount: localAccount), api: api)
            let assetDetailGroupFetchOperation =
                AssetDetailGroupFetchOperation(input: .init(), api: api)
            let adapterOperation = BlockOperation {
                [weak self, unowned accountFetchOperation, unowned assetDetailGroupFetchOperation] in
                guard let self = self else { return }
                
                var input = AssetDetailGroupFetchOperation.Input()
                
                switch accountFetchOperation.result {
                case .success(let output):
                    let account = output.account
                    
                    self.send(blockEvent: .didFetchAccount(account))
                    
                    input.account = account
                    input.cachedAccounts = self.currentBlockRequest?.cachedAccounts ?? []
                    input.cachedAssetDetails = self.currentBlockRequest?.cachedAssetDetails ?? []
                    
                    self.send(blockEvent: .willFetchAssetDetails(accountAddress: account.address))
                case .failure(let error):
                    self.send(
                        blockEvent: .didFailToFetchAccount(
                            address: accountFetchOperation.input.localAccount.address,
                            error: error
                        )
                    )
                    
                    input.error = error
                }
                
                assetDetailGroupFetchOperation.input = input
            }
            let finishOperation = BlockOperation {
                [weak self, unowned assetDetailGroupFetchOperation] in
                guard let self = self else { return }
                
                switch assetDetailGroupFetchOperation.result {
                case .success(let output):
                    self.send(
                        blockEvent: .didFetchAssetDetails(
                            output.newAssetDetails,
                            accountAddress: output.account.address
                        )
                    )
                case .failure(let error):
                    if let account = assetDetailGroupFetchOperation.input.account {
                        self.send(
                            blockEvent: .didFailToFetchAssetDetails(
                                accountAddress: account.address,
                                error: error
                            )
                        )
                    }
                }
                
                self.queue.dequeueOperations(forAccountAddress: localAccount.address)
            }
            
            finishOperation.addDependency(assetDetailGroupFetchOperation)
            assetDetailGroupFetchOperation.addDependency(adapterOperation)
            adapterOperation.addDependency(accountFetchOperation)
            
            let operations = [
                accountFetchOperation,
                adapterOperation,
                assetDetailGroupFetchOperation,
                finishOperation
            ]
            
            queue.enqueue(
                operations,
                forAccountAddress: localAccount.address
            )
        }
        
        queue.addBarrier { [weak self] in
            guard let self = self else { return }
            self.send(blockEvent: .didFinish)
        }
    }
}

extension ALGBlockProcessor {
    private func send(
        blockEvent event: BlockEvent
    ) {
        blockEventQueue?.async { [weak self] in
            guard let self = self else { return }
            self.blockEventHandler?(event)
        }
    }
}
