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

            self.process()
        }
    }
    
    func stop() {
        watcher.stop()
    }
}

extension BlockProcessor {
    private func process() {
        session.authenticatedUser?.accounts.forEach { account in
            let op = createFetchOperation(for: account)
            queue.enqueue(op)
            
            session[account] = .loading(account)
        }
    }
    
    private func createFetchOperation(
        for account: AccountInformation
    ) -> Operation {
        let operation = AccountDetailFetchOperation(account: account, api: api)
        operation.completionHandler = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let accountDetail):
                break
            case .failure(let error):
                break
            }
        }
        return operation
    }
    
    private func createAssetFetchOperation(
        for accountDetail: Account
    ) -> Operation {
        return BlockOperation { [weak self, weak accountDetail] in
            guard
                let self = self,
                let accountDetail = accountDetail
            else { return }
        }
    }
}
