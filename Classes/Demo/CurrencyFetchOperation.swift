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

//
//   CurrencyFetchOperation.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class CurrencyFetchOperation: MacaroonUtils.AsyncOperation {
    typealias Error = HIPNetworkError<NoAPIModel>
    typealias CompletionHandler = (Result<Output, Error>) -> Void
    
    var completionHandler: CompletionHandler?
    
    private var ongoingEndpoint: EndpointOperatable?

    private let input: Input
    private let api: ALGAPI
    private let completionQueue =
        DispatchQueue(label: "com.algorand.queue.operation.currencyFetch", qos: .userInitiated)
    
    init(
        input: Input,
        api: ALGAPI
    ) {
        self.input = input
        self.api = api
    }
    
    override func main() {
        if finishIfCancelled() {
            return
        }
        
        ongoingEndpoint =
            api.getCurrencyValue(
                input.currencyFetchId,
                queue: completionQueue
            ) { [weak self] result in
                guard let self = self else { return }
                
                self.ongoingEndpoint = nil
                
                switch result {
                case .success(let currency):
                    let outputCurrency: Currency
                    
                    if self.input.isAlgo {
                        outputCurrency = AlgoCurrency(currency: currency)
                    } else {
                        outputCurrency = currency
                    }
                    
                    let output = Output(currency: outputCurrency)
                    self.completionHandler?(.success(output))
                case .failure(let apiError, let apiErrorDetail):
                    let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    self.completionHandler?(.failure(error))
                }
                
                self.finish()
            }
    }

    override func finishIfCancelled() -> Bool {
        if !isCancelled {
            return false
        }

        completionHandler?(.failure(.connection(.init(reason: .cancelled))))
        finish()

        return true
    }
    
    override func cancel() {
        cancelOngoingEndpoint()
        super.cancel()
    }
}

extension CurrencyFetchOperation {
    private func cancelOngoingEndpoint() {
        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
    }
}

extension CurrencyFetchOperation {
    struct Input {
        let currencyId: String
        
        var currencyFetchId: String {
            isAlgo ? "USD" : currencyId
        }
        
        var isAlgo: Bool {
            currencyId == "ALGO"
        }
    }
    
    struct Output {
        let currency: Currency
    }
}
