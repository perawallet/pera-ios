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
//   WCGroupTransactionHeaderViewModel.swift

import UIKit

class WCGroupTransactionHeaderViewModel {
    private(set) var transactionDappMessageViewModel: WCTransactionDappMessageViewModel?
    private(set) var title: String?

    init(session: WCSession, transactionParameter: WCTransactionParams, transactionCount: Int) {
        setTransactionDappMessageViewModel(from: session, and: transactionParameter)
        setTitle(from: transactionCount)
    }

    private func setTransactionDappMessageViewModel(from session: WCSession, and transactionParameter: WCTransactionParams) {
        transactionDappMessageViewModel = WCTransactionDappMessageViewModel(
            session: session,
            transactionParameter: transactionParameter,
            imageSize: CGSize(width: 44.0, height: 44.0)
        )
    }

    private func setTitle(from transactionCount: Int) {
        title = "wallet-connect-transaction-count".localized(transactionCount)
    }
}
