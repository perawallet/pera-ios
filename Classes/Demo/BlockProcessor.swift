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
//   BlockProcessor.swift


import Foundation

final class BlockProcessor {
    private lazy var queue = BlockOperationQueue()
    
    private let watcher: BlockWatcher
    private let session: Session
    private let api: ALGAPI
    
    init(
        watcher: BlockWatcher,
        session: Session,
        api: ALGAPI
    ) {
        self.watcher = watcher
        self.session = session
        self.api = api
    }
}

extension BlockProcessor {
    func start() {
        watcher.start { [weak self] in
            guard let self = self else { return }
            
            self.enqueueAccountDetailFetches()
            self.enqueueAssetDetailGroupFetches()
        }
    }
    
    func stop() {
        watcher.stop()
    }
}

extension BlockProcessor {
    private func enqueueAccountDetailFetches() {
        let accounts = session.authenticatedUser?.accounts

        accounts?.forEach {
            let op = AccountDetailFetchOperation(account: $0, api: api)
            op.completionHandler = { result in
                
            }
            
            queue.enqueue(op)
        }
    }
    
    private func enqueueAssetDetailGroupFetches() {
        
    }
}
