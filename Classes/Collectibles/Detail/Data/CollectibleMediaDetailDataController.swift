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

//   CollectibleMediaDetailDataController.swift

import Foundation
import UIKit

protocol CollectibleMediaDetailDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<CollectibleMediaDetailSection, CollectibleMediaDetailItem>

    var eventHandler: ((CollectibleMediaDetailDataControllerEvent) -> Void)? { get set }

    func load()
}

enum CollectibleMediaDetailSection:
    Int,
    Hashable {
    case media
}

enum CollectibleMediaDetailItem: Hashable {
    case item
}

enum CollectibleMediaDetailDataControllerEvent {
    case didUpdate(CollectibleMediaDetailDataController.Snapshot)

    var snapshot: CollectibleMediaDetailDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot):
            return snapshot
        }
    }
}
