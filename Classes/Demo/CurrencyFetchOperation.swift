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
//   CurrencyFetchOperation.swift


import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class CurrencyFetchOperation: MacaroonUtils.AsyncOperation {
    typealias CompletionHandler = (Result<Currency, HIPNetworkError<NoJSONModel>>) -> Void
    
    var completionHandler: CompletionHandler?
    
    private var endpoint: EndpointOperatable?
    
    private let api: ALGAPI
    
    init(
        api: ALGAPI
    ) {
        self.api = api
    }
    
    override func main() {
        endpoint = api.getCurrencyValue(api.session.preferredCurrency) { [weak self] result in
            guard let self = self else { return }
            
            if self.finishIfCancelled() {
                return
            }
            
            self.endpoint = nil
            
            switch result {
            case .success(let currency):
                /// <todo>
                /// ???
                self.api.session.preferredCurrencyDetails = currency
                self.completionHandler?(.success(currency))
            case .failure(let apiError, _):
                self.completionHandler?(.failure(.init(apiError: apiError, apiErrorDetail: nil)))
            }
        }
    }
    
    override func cancel() {
        super.cancel()
        
        endpoint?.cancel()
        endpoint = nil
    }
}
