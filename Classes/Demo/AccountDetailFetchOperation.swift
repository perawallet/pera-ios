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
//   AccountDetailFetchOperation.swift


import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class AccountDetailFetchOperation: MacaroonUtils.AsyncOperation {
    typealias CompletionHandler = (Result<Account, HIPNetworkError<NoAPIModel>>) -> Void
    
    var completionHandler: CompletionHandler?
    
    private var ongoingEndpoint: EndpointOperatable?
    
    private let account: AccountInformation
    private let api: ALGAPI
    
    init(
        account: AccountInformation,
        api: ALGAPI
    ) {
        self.account = account
        self.api = api
    }
    
    override func main() {
        if finishIfCancelled() {
            return
        }
        
        let draft = AccountFetchDraft(publicKey: account.address)

        /// <todo>
        /// Thread???
        ongoingEndpoint =
            api.fetchAccount(draft) { [weak self] result in
                guard let self = self else { return }

                if self.finishIfCancelled() {
                    return
                }
            
                self.ongoingEndpoint = nil
                
                switch result {
                case .success(let response):
                    let accountDetail = response.account
                    /// <todo>
                    /// ???
                    accountDetail.assets = accountDetail.nonDeletedAssets()
                    accountDetail.update(from: self.account)
                    self.completionHandler?(.success(accountDetail))
                case .failure(let apiError, let apiErrorDetail):
                    if apiError.isHttpNotFound {
                        let accountDetail = Account(accountInformation: self.account)
                        self.completionHandler?(.success(accountDetail))
                    } else {
                        let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                        self.completionHandler?(.failure(error))
                    }
                }
        }
    }
    
    override func cancel() {
        super.cancel()
        
        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
    }
}
