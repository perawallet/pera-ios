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

//   CurrencyDataRequest.swift

struct CurrencyDataRequest {
    /// The unique identifier of the currency for which data is being requested.
    let currencyID: String
}

extension CurrencyDataRequest: Requestable {
    
    typealias ResponseType = CurrencyDataResponse
    
    var path: String { "/currencies/\(currencyID)" }
    var method: RequestMethod { .get }
}

struct CurrencyDataResponse: Decodable {
    
    /// The timestamp indicating when the currency data was generated.
    let generatedAt: String
    /// A unique identifier for the currency.
    let currencyId: String
    /// The full name of the currency.
    let name: String
    /// The currency symbol or ticker.
    let symbol: String
    /// The current exchange price.
    let exchangePrice: String
    /// The timestamp indicating when the currency data was last updated.
    let lastUpdatedAt: String
    /// The numeric USD value of the currency.
    let usdValue: Double
}
