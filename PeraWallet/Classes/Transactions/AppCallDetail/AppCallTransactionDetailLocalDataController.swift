// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AppCallTransactionDetailLocalDataController.swift

import pera_wallet_core

final class AppCallTransactionDetailLocalDataController: AppCallTransactionDetailDataController {
    var eventHandler: EventHandler?
    
    private let api: ALGAPI?
    var transaction: TransactionV2?
    
    init(_ api: ALGAPI?) {
        self.api = api
    }
    
    func loadTransactionDetail(account: Account, transactionId: String?) {
        guard let transactionId else { return }
        
        api?.fetchTransactionDetailV2(TransactionV2FetchDetailDraft(account: account, transactionId: transactionId)) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let transactionDetail):
                transaction = transactionDetail
                eventHandler?(.didLoad(transaction: transactionDetail))
            case .failure(let apiError, _):
                transaction = nil
                eventHandler?(.didFail(error: apiError))
            }
        }
    }
}



