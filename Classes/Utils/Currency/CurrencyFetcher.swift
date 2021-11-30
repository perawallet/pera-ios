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
//   CurrencyController.swift

import Foundation
import MagpieCore

final class CurrencyFetcher: CurrencyFetching {
    private let api: ALGAPI
    private var currencyDetailRequest: EndpointOperatable?

    lazy var handlers = Handlers()

    init(
        api: ALGAPI
    ) {
        self.api = api
    }

    func getPreferredCurrencyDetails() {
        currencyDetailRequest = api.getCurrencyValue(api.session.preferredCurrency) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(currency):
                self.setPreferredCurrencyDetails(currency)
                self.handlers.didFetchCurrencyDetails?(currency)
            case let .failure(error, _):
                self.handlers.didFailFetchingCurrencyDetails?(error)
            }
        }
    }

    func cancelCurrencyDetailRequest() {
        currencyDetailRequest?.cancel()
    }
}

extension CurrencyFetcher {
    private func setPreferredCurrencyDetails(
        _ currency: Currency
    ) {
        api.session.preferredCurrencyDetails = currency
    }
}

extension CurrencyFetcher {
    struct Handlers {
        var didFetchCurrencyDetails: ((Currency) -> Void)?
        var didFailFetchingCurrencyDetails: ((APIError) -> Void)?
    }
}

protocol CurrencyFetching {
    func getPreferredCurrencyDetails()
    func cancelCurrencyDetailRequest()
}

typealias CurrencyID = String
