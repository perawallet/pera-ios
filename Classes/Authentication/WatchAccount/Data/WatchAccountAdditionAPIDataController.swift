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

//   WatchAccountAdditionAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class WatchAccountAdditionAPIDataController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var nameServiceSearchThrottler = Throttler(intervalInSeconds: 0.3)

    private var ongoingNameServicesEndpoint: EndpointOperatable?

    private let api: ALGAPI

    init(api: ALGAPI) {
        self.api = api
    }

    deinit {
        cancelNameServiceSearchingIfNeeded()
    }
}

extension WatchAccountAdditionAPIDataController {
    func searchNameServices(for query: String?) {
        let task = {
            [weak self] in
            guard let self = self else {
                return
            }

            self.cancelOngoingNameServicesEndpoint()

            self.publish(.willLoadNameServices)

            let query = NameServiceQuery(name: query)
            self.ongoingNameServicesEndpoint = self.api.fetchNameServices(query) {
                [weak self] result in
                guard let self = self else { return }

                self.ongoingNameServicesEndpoint = nil

                switch result {
                case .success(let nameServiceList):
                    let nameServices = nameServiceList.results
                    self.publish(.didLoadNameServices(nameServices))
                case .failure:
                    self.publish(.didFailLoadingNameServices)
                }
            }
        }

        nameServiceSearchThrottler.performNext(task)
    }

    func cancelNameServiceSearchingIfNeeded() {
        let isNotSearching = ongoingNameServicesEndpoint.isNilOrFinished

        if isNotSearching {
            return
        }

        nameServiceSearchThrottler.cancelAll()
        cancelOngoingNameServicesEndpoint()
    }

    private func cancelOngoingNameServicesEndpoint() {
        ongoingNameServicesEndpoint?.cancel()
        ongoingNameServicesEndpoint = nil
    }
}

extension WatchAccountAdditionAPIDataController {
    func shouldSearchNameServices(for query: String?) -> Bool {
        if let query = query,
           !query.isEmptyOrBlank,
           query.containsNameService {
            return true
        }

        return false
    }
}

 extension WatchAccountAdditionAPIDataController {
     private func publish(_ event: Event) {
         asyncMain {
             [weak self] in
             guard let self = self else { return }

             self.eventHandler?(event)
         }
     }
 }

extension WatchAccountAdditionAPIDataController {
    enum Event {
        case willLoadNameServices
        case didLoadNameServices([NameService])
        case didFailLoadingNameServices
    }
}
