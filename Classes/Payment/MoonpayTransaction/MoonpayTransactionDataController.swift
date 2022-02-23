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

//   MoonpayTransactionDataController.swift

import Foundation

final class MoonpayTransactionDataController: NSObject {
    weak var delegate: MoonpayTransactionDataControllerDelegate?
    
    private let sharedDataController: SharedDataController
    
    init(sharedDataController: SharedDataController) {
        self.sharedDataController = sharedDataController
        super.init()
    }
    
    func getDataFor(accountAddress: String) {
        searchAccount(accountAddress)
    }
    
    func searchAccount(_ address: String) {
        let account = sharedDataController.accountCollection.account(for: address)
        
        guard let account = account else {
            return
        }
        
        let type = account.type
        
        if let name = account.name {
            delegate?.MoonpayTransactionDataControllerDidFindAccount(self, accountName: name, accountType: type)
            return
        }
        
        delegate?.MoonpayTransactionDataControllerDidFindAccount(self, accountName: address, accountType: type)
    }
}

protocol MoonpayTransactionDataControllerDelegate: AnyObject {
    func MoonpayTransactionDataControllerDidFindAccount(
        _ dataController: MoonpayTransactionDataController,
        accountName: String,
        accountType: AccountType
    )
}
