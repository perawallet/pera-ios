// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CardsSupportedCountriesFlowCoordinator.swift

import Foundation
import UIKit

final class CardsSupportedCountriesFlowCoordinator {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private let api: ALGAPI

    init(api: ALGAPI) {
        self.api = api
    }
}

extension CardsSupportedCountriesFlowCoordinator {
    func launch() {
        api.fetchCardsAvailableCountries { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let result):
                guard let supportedRegion = result.regions.first(where: { $0.country.countryCode == result.currentRegion.countryCode })  else {
                    self.eventHandler?(.error(nil))
                    return
                }
                self.eventHandler?(.success(supportedRegion))
            case .failure(let error, _):
                self.eventHandler?(.error(error))
            }
        }
    }
}

extension CardsSupportedCountriesFlowCoordinator {
    enum Event {
        case success(SupportedRegion)
        case error(Error?)
    }
}

