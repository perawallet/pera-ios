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
//   AccountsPortfolioAPIDataController.swift

import Foundation

final class HomeAPIDataController:
    HomeDataController,
    SharedDataControllerObserver {
    var eventHandler: ((HomeDataControllerEvent) -> Void)?
    
    private var accounts: [AccountHandle] = []
    private var watchAccounts: [AccountHandle] = []
    
    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.homeDataController")
    
    init(
        _ sharedDataController: SharedDataController
    ) {
        self.sharedDataController = sharedDataController
    }
    
    deinit {
        sharedDataController.remove(self)
    }
}

extension HomeAPIDataController {
    func load() {
        sharedDataController.add(self)
    }
}

extension HomeAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didStartRunning(let first):
            if first {
                deliverLoadingSnapshot()
            } else {
                deliverContentSnapshot()
            }
        case .didFinishRunning:
            deliverContentSnapshot()
        case .didBecomeIdle:
            deliverLoadingSnapshot()
        default:
            break
        }
    }
}

extension HomeAPIDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.loading)],
                toSection: .empty
            )
            return snapshot
        }
    }
    
    private func deliverContentSnapshot() {
        if sharedDataController.accountCollection.isEmpty {
            deliverNoContentSnapshot()
            return
        }
        
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }
            
            let accountCollection = self.sharedDataController.accountCollection
            
            var snapshot = Snapshot()
            
            snapshot.appendSections([.portfolio])
            snapshot.appendItems(
                [.portfolio(AccountPortfolioViewModel(accountCollection))],
                toSection: .portfolio
            )
            
            /// <todo>
            /// Add announcement section

            var accounts: [AccountHandle] = []
            var accountItems: [HomeItem] = []
            var watchAccounts: [AccountHandle] = []
            var watchAccountItems: [HomeItem] = []
            
            accountCollection
                .sorted {
                    $0.value.preferredOrder < $1.value.preferredOrder
                }
                .forEach {
                    let isNonWatchAccount = $0.value.type != .watch
                    let item: HomeItem = .account(AccountPreviewViewModel(account: $0))
                
                    if isNonWatchAccount {
                        accounts.append($0)
                        accountItems.append(item)
                    } else {
                        watchAccounts.append($0)
                        watchAccountItems.append(item)
                    }
                }
            
            self.accounts = accounts
            
            if !accounts.isEmpty {
                snapshot.appendSections([.accounts])
                snapshot.appendItems(
                    accountItems,
                    toSection: .accounts
                )
            }
            
            self.watchAccounts = watchAccounts
            
            if !watchAccounts.isEmpty {
                snapshot.appendSections([.watchAccounts])
                snapshot.appendItems(
                    watchAccountItems,
                    toSection: .watchAccounts
                )
            }
            
            return snapshot
        }
    }
    
    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.noContent)],
                toSection: .empty
            )
            return snapshot
        }
    }
    
    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }
            
            let newSnapshot = snapshot()
            self.publish(.didUpdate(newSnapshot))
        }
    }
}

extension HomeAPIDataController {
    private func publish(
        _ event: HomeDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            
            self.eventHandler?(event)
        }
    }
}
