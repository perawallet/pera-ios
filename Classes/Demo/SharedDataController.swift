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
//   SharedDataController.swift


import Foundation
import MacaroonUtils

protocol SharedDataController: AnyObject {
    var assetDetailCollection: AssetDetailCollection { get set }
    var accountCollection: AccountCollection { get }
    var currency: CurrencyHandle { get }
    
    func startPolling()
    func stopPolling()
    func reset() /// stop polling -> delete data -> start polling
    func cancel() /// stop polling -> delete data
    
    func add(
        _ observer: SharedDataControllerObserver
    )
    func remove(
        _ observer: SharedDataControllerObserver
    )
}

/// <todo>
/// Can this approach move to 'Macaroon' library???
///
/// <note>
/// Observers will be notified on the main thread.
protocol SharedDataControllerObserver: AnyObject {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    )
}

enum SharedDataControllerEvent {
    case didStartRunning(first: Bool)
    case didUpdateAccountCollection(AccountHandle)
    case didUpdateAssetDetailCollection
    case didUpdateCurrency
    case didFinishRunning
    case didBecomeIdle
}
