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

//   CollectibleDetailAPIDataController.swift

import Foundation
import MacaroonUtils

final class CollectibleDetailAPIDataController: CollectibleDetailDataController {

    var eventHandler: ((CollectibleDetailDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.collectibleDetailDataController")
}

extension CollectibleDetailAPIDataController {
    func load() {

    }
}

extension CollectibleDetailAPIDataController {
    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }
            self.publish(.didUpdate(snapshot()))
        }
    }
}

extension CollectibleDetailAPIDataController {
    private func publish(
        _ event: CollectibleDetailDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}
