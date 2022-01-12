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
//   SharedAPIDataController.swift


import Foundation

final class SharedAPIDataController: SharedDataController {
    private(set) var accountCollection: AccountCollection = []
    private(set) var assetDetailCollection: AssetDetailCollection = []
    
    private lazy var blockProcessor = createBlockProcessor()
    private lazy var blockProcessorEventQueue =
        DispatchQueue(label: "com.algorand.queue.blockProcessor.events")
    
    private let session: Session
    private let api: ALGAPI
    
    init(
        session: Session,
        api: ALGAPI
    ) {
        self.session = session
        self.api = api
    }
    
    func start() {
        blockProcessor.start()
    }
    
    func stop() {
        blockProcessor.stop()
    }
}

extension SharedAPIDataController {
    private func createBlockProcessor() -> BlockProcessor {
        let request: ALGBlockProcessor.BlockRequest = { [unowned self] in
            var request = ALGBlockRequest()
            request.localAccounts = self.session.authenticatedUser?.accounts ?? []
            request.cachedAccounts = self.accountCollection
            request.cachedAssetDetails = self.assetDetailCollection
            return request
        }
        let cycle = ALGBlockCycle(api: api)
        let processor = ALGBlockProcessor(blockRequest: request, blockCycle: cycle, api: api)
        
        processor.notify(queue: blockProcessorEventQueue) {
            [weak self] event in
            guard let self = self else { return }
            
            print(event)
        }
        
        return processor
    }
}
