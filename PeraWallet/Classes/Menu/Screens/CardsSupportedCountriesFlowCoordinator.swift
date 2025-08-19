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

//   CardsSupportedCountriesFlowCoordinator.swift

import Foundation
import UIKit
import pera_wallet_core

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
        getCardsFundAddressesList()
    }
    
    private func getCardsFundAddressesList() {
        let addresses = session.authenticatedUser?.accounts.filter { !$0.isWatchAccount }.map { $0.address } ?? []
        api.fetchCardsFundAddressesList(addresses: addresses) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let result):
                if result.results.contains(where: { $0.cardFundAddress != nil }) {
                    self.eventHandler?(.success(hasActiveCard: true, isWaitlisted: false))
                } else {
                    getCardsCountryAvailability()
                }
            case .failure(let error, _):
                self.eventHandler?(.error(error))
            }
        }
    }
    
    private func getCardsCountryAvailability() {
        api.fetchCardsCountryAvailability(deviceId: session.authenticatedUser?.getDeviceId(on: api.network))  { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let result):
                self.eventHandler?(.success(hasActiveCard: false, isWaitlisted: result.isWaitlisted))
            case .failure(let error, _):
                self.eventHandler?(.error(error))
            }
        }
    }
}

extension CardsSupportedCountriesFlowCoordinator {
    enum Event {
        case success(hasActiveCard: Bool, isWaitlisted: Bool)
        case error(Error?)
    }
}

