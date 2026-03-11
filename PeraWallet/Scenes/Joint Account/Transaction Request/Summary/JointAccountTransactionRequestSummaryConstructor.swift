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

//   JointAccountTransactionRequestSummaryConstructor.swift

import UIKit

enum JointAccountTransactionRequestSummaryConstructor {
    
    static func buildScene(legacyConfiguration: ViewControllerConfiguration, transactionController: TransactionController, request: SignRequestObject) -> UIViewController {
        let model = JointAccountTransactionRequestSummaryModel(transactionController: transactionController, accountsService: PeraCoreManager.shared.accounts, currencyService: PeraCoreManager.shared.currencies, request: request)
        return JointAccountTransactionRequestSummaryViewController(legacyConfiguration: legacyConfiguration, accountsService: PeraCoreManager.shared.accounts, model: model)
    }
}
