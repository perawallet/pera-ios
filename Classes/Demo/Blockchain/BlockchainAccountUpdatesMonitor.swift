// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   BlockchainAccountUpdatesMonitor.swift

import Foundation

struct BlockchainAccountUpdatesMonitor {
    let accountAddress: String

    private var optInUpdates: [AssetID : OptInBlockchainUpdate] = [:]

    init(accountAddress: String) {
        self.accountAddress = accountAddress
    }
}

extension BlockchainAccountUpdatesMonitor {
    func hasMonitoringUpdates() -> Bool {
        return !optInUpdates.isEmpty
    }
}

extension BlockchainAccountUpdatesMonitor {
    func filterPendingOptInAssetUpdates() -> [AssetID : OptInBlockchainUpdate] {
        return optInUpdates.filter { $0.value.status == .pending }
    }

    func filterOptedInAssetUpdates() -> [AssetID : OptInBlockchainUpdate] {
        return optInUpdates.filter { $0.value.status == .waitingForNotification }
    }
}

extension BlockchainAccountUpdatesMonitor {
    func hasPendingOptInRequest(assetID: AssetID) -> Bool {
        let update = optInUpdates[assetID]
        return update?.status == .pending
    }

    mutating func startMonitoringOptInUpdates(_ request: OptInBlockchainRequest) {
        let update = OptInBlockchainUpdate(request: request)
        optInUpdates[update.assetID] = update
    }

    mutating func stopMonitoringOptInUpdates(forAssetID assetID: AssetID) {
        guard let pendingUpdate = optInUpdates[assetID] else { return }

        let waitingUpdate = OptInBlockchainUpdate(
            update: pendingUpdate,
            status: .waitingForNotification
        )
        optInUpdates[assetID] = waitingUpdate
    }

    mutating func finishMonitoringOptInUpdates(forAssetID assetID: AssetID) {
        optInUpdates[assetID] = nil
    }
}

extension BlockchainAccountUpdatesMonitor {
    mutating func removeUnmonitoredUpdates() {
        optInUpdates = filterPendingOptInAssetUpdates()
    }
}

extension BlockchainAccountUpdatesMonitor {
    func makeBatchRequest() -> BlockchainAccountBatchRequest {
        var pendingOptInUpdates: [AssetID : Any] = [:]
        for update in optInUpdates where update.value.status == .pending {
            pendingOptInUpdates[update.key] = true
        }

        var batchRequest = BlockchainAccountBatchRequest()
        batchRequest.optInAssets = pendingOptInUpdates

        return batchRequest
    }
}
