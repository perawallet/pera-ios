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
    private let session: Session

    init(api: ALGAPI, session: Session) {
        self.api = api
        self.session = session
    }
}

extension CardsSupportedCountriesFlowCoordinator {
    func launch() {
        getCardsCountryAvailability()
    }
    
    private func getCardsCountryAvailability() {
        api.fetchCardsCountryAvailability(deviceId: session.authenticatedUser?.getDeviceId(on: api.network))  { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let result):
                getCardsAvailableCountries(isWaitlisted: result.isWaitlisted)
            case .failure:
                getCardsAvailableCountries(isWaitlisted: false)
            }
        }
    }
    
    private func getCardsAvailableCountries(isWaitlisted: Bool) {
        api.fetchCardsAvailableCountries { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let result):
                guard let supportedRegion = result.regions.first(where: { $0.country.countryCode == result.currentRegion.countryCode })  else {
                    self.eventHandler?(.error(nil))
                    return
                }
                self.eventHandler?(.success(supportedRegion, isWaitlisted))
            case .failure(let error, _):
                self.eventHandler?(.error(error))
            }
        }
    }
}

extension CardsSupportedCountriesFlowCoordinator {
    enum Event {
        case success(SupportedRegion, Bool)
        case error(Error?)
    }
}

