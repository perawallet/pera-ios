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
//  Currency.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class Currency: ALGEntityModel {
    let id: String
    let name: String?
    let price: String?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.currencyId ?? "USD"
        self.name = apiModel.name
        self.price = apiModel.exchangePrice
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.currencyId = id
        apiModel.name = name
        apiModel.exchangePrice = price
        return apiModel
    }
}

extension Currency {
    struct APIModel: ALGAPIModel {
        var currencyId: String?
        var name: String?
        var exchangePrice: String?

        init() {
            self.currencyId = nil
            self.name = nil
            self.exchangePrice = nil
        }
    }
}

extension Currency: Equatable {
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.id == rhs.id
    }
}
