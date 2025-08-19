// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   BlockchainUpdatesMonitor.swift

import Foundation
import MacaroonUtils

public struct BlockchainUpdatesMonitor: Printable {
    public typealias AccountAddress = String

    public var debugDescription: String {
        return table.debugDescription
    }

    private typealias Table = [AccountAddress: BlockchainAccountUpdatesMonitor]

    @Atomic(identifier: "blockchainMonitor.table")
    private var table: Table = [:]
}

extension BlockchainUpdatesMonitor {
    public func filterPendingOptInAssetUpdates() -> [OptInBlockchainUpdate] {
        return table.reduce(into: [OptInBlockchainUpdate]()) {
            $0 += $1.value.filterPendingOptInAssetUpdates().values
        }
    }

    public func filterPendingOptInAssetUpdates(for account: Account) -> [AssetID : OptInBlockchainUpdate] {
        let address = account.address
        let monitor = table[address]
        return monitor?.filterPendingOptInAssetUpdates() ?? [:]
    }

    public func filterOptedInAssetUpdates() -> [OptInBlockchainUpdate] {
        return table.reduce(into: [OptInBlockchainUpdate]()) {
            $0 += $1.value.filterOptedInAssetUpdates().values
        }
    }

    public func filterOptedInAssetUpdatesForNotification() -> [OptInBlockchainUpdate] {
        return table.reduce(into: [OptInBlockchainUpdate]()) {
            $0 += $1.value.filterOptedInAssetUpdatesForNotification().values
        }
    }

    public func filterOptedInAssetUpdates(for account: Account) -> [AssetID : OptInBlockchainUpdate] {
        let address = account.address
        let monitor = table[address]
        return monitor?.filterOptedInAssetUpdates() ?? [:]
    }
}

extension BlockchainUpdatesMonitor {
    public func hasAnyPendingOptInRequest(for account: Account) -> Bool {
        let address = account.address
        let monitor = table[address]
        return monitor?.hasAnyPendingOptInRequest() ?? false
    }

    public func hasPendingOptInRequest(
        assetID: AssetID,
        for account: Account
    ) -> Bool {
        let address = account.address
        let monitor = table[address]
        return monitor?.hasPendingOptInRequest(assetID: assetID) ?? false
    }

    public func startMonitoringOptInUpdates(_ request: OptInBlockchainRequest) {
        let address = request.accountAddress

        var monitor = table[address] ?? .init(accountAddress: address)
        monitor.startMonitoringOptInUpdates(request)

        $table.mutate { $0[address] = monitor }
    }

    public func markOptInUpdatesForNotification(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.markOptInUpdatesForNotification(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }

    public func stopMonitoringOptInUpdates(associatedWith update: OptInBlockchainUpdate) {
        let address = update.accountAddress

        guard var monitor = table[address] else { return }

        monitor.stopMonitoringOptInUpdates(forAssetID: update.assetID)

        $table.mutate { $0[address] = monitor }
    }

    public func cancelMonitoringOptInUpdates(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.cancelMonitoringOptInUpdates(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }
}

extension BlockchainUpdatesMonitor {
    public func filterPendingOptOutAssetUpdates() -> [OptOutBlockchainUpdate] {
        return table.reduce(into: [OptOutBlockchainUpdate]()) {
            $0 += $1.value.filterPendingOptOutAssetUpdates().values
        }
    }

    public func filterPendingOptOutAssetUpdates(for account: Account) -> [AssetID : OptOutBlockchainUpdate] {
        let address = account.address
        let monitor = table[address]
        return monitor?.filterPendingOptOutAssetUpdates() ?? [:]
    }

    public func filterOptedOutAssetUpdates() -> [OptOutBlockchainUpdate] {
        return table.reduce(into: [OptOutBlockchainUpdate]()) {
            $0 += $1.value.filterOptedOutAssetUpdates().values
        }
    }

    public func filterOptedOutAssetUpdatesForNotification() -> [OptOutBlockchainUpdate] {
        return table.reduce(into: [OptOutBlockchainUpdate]()) {
            $0 += $1.value.filterOptedOutAssetUpdatesForNotification().values
        }
    }

    public func filterOptedOutAssetUpdates(for account: Account) -> [AssetID: OptOutBlockchainUpdate] {
        let address = account.address
        let monitor = table[address]
        return monitor?.filterOptedOutAssetUpdates() ?? [:]
    }
}

extension BlockchainUpdatesMonitor {
    public func hasAnyPendingOptOutRequest(for account: Account) -> Bool {
        let address = account.address
        let monitor = table[address]
        return monitor?.hasAnyPendingOptOutRequest() ?? false
    }

    public func hasPendingOptOutRequest(
        assetID: AssetID,
        for account: Account
    ) -> Bool {
        let address = account.address
        let monitor = table[address]
        return monitor?.hasPendingOptOutRequest(assetID: assetID) ?? false
    }

    public func startMonitoringOptOutUpdates(_ request: OptOutBlockchainRequest) {
        let address = request.accountAddress

        var monitor = table[address] ?? .init(accountAddress: address)
        monitor.startMonitoringOptOutUpdates(request)

        $table.mutate { $0[address] = monitor }
    }

    public func markOptOutUpdatesForNotification(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.markOptOutUpdatesForNotification(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }

    public func stopMonitoringOptOutUpdates(associatedWith update: OptOutBlockchainUpdate) {
        let address = update.accountAddress

        guard var monitor = table[address] else { return }

        monitor.stopMonitoringOptOutUpdates(forAssetID: update.assetID)

        $table.mutate { $0[address] = monitor }
    }

    public func cancelMonitoringOptOutUpdates(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.cancelMonitoringOptOutUpdates(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }
}

extension BlockchainUpdatesMonitor {
    /// <todo>
    /// We may change the naming to pending send to pending transfer. It fits better.
    public func filterPendingSendPureCollectibleAssetUpdates() -> [SendPureCollectibleAssetBlockchainUpdate] {
        return table.reduce(into: [SendPureCollectibleAssetBlockchainUpdate]()) {
            $0 += $1.value.filterPendingSendPureCollectibleAssetUpdates().values
        }
    }

    public func filterPendingSendPureCollectibleAssetUpdates(for account: Account) -> [AssetID : SendPureCollectibleAssetBlockchainUpdate] {
        let address = account.address
        let monitor = table[address]
        return monitor?.filterPendingSendPureCollectibleAssetUpdates() ?? [:]
    }

    public func filterSentPureCollectibleAssetUpdates() -> [SendPureCollectibleAssetBlockchainUpdate] {
        return table.reduce(into: [SendPureCollectibleAssetBlockchainUpdate]()) {
            $0 += $1.value.filterSentPureCollectibleAssetUpdates().values
        }
    }

    public func filterSentPureCollectibleAssetUpdatesForNotification() -> [SendPureCollectibleAssetBlockchainUpdate] {
        return table.reduce(into: [SendPureCollectibleAssetBlockchainUpdate]()) {
            $0 += $1.value.filterSentPureCollectibleAssetUpdatesForNotification().values
        }
    }
}

extension BlockchainUpdatesMonitor {
    public func hasPendingSendPureCollectibleAssetRequest(
        assetID: AssetID,
        for account: Account
    ) -> Bool {
        let address = account.address
        let monitor = table[address]
        return monitor?.hasPendingSendPureCollectibleAssetRequest(assetID: assetID) ?? false
    }

    public func startMonitoringSendPureCollectibleAssetUpdates(_ request: SendPureCollectibleAssetBlockchainRequest) {
        let address = request.accountAddress

        var monitor = table[address] ?? .init(accountAddress: address)
        monitor.startMonitoringSendPureCollectibleAssetUpdates(request)

        $table.mutate { $0[address] = monitor }
    }

    public func markSendPureCollectibleAssetUpdatesForNotification(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.markSendPureCollectibleAssetUpdatesForNotification(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }

    public func stopMonitoringSendPureCollectibleAssetUpdates(associatedWith update: SendPureCollectibleAssetBlockchainUpdate) {
        let address = update.accountAddress

        guard var monitor = table[address] else { return }

        monitor.stopMonitoringSendPureCollectibleAssetUpdates(forAssetID: update.assetID)

        $table.mutate { $0[address] = monitor }
    }

    private func cancelMonitoringSendPureCollectibleAssetUpdates(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.markSendPureCollectibleAssetUpdatesForNotification(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }
}

extension BlockchainUpdatesMonitor {
    public func removeCompletedUpdates() {
        $table.mutate {
            var newTable: Table = [:]
            for (address, monitor) in $0 {
                var mMonitor = monitor
                mMonitor.removeCompletedUpdates()

                if mMonitor.hasMonitoringUpdates() {
                    newTable[address] = mMonitor
                }
            }

            $0 = newTable
        }
    }
}

extension BlockchainUpdatesMonitor {
    public func makeBatchRequest() -> BlockchainBatchRequest {
        return table.mapValues { $0.makeBatchRequest() }
    }
}
