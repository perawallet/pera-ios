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
//   WCTransactionRequestBottomViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCSingleTransactionRequestBottomViewModel {
    private(set) var senderAddress: String?
    private(set) var networkFee: String?
    private(set) var warningMessage: String?
    private(set) var assetIcon: UIImage?

    init(transaction: WCTransaction, account: Account?) {
        let fee = transaction.transactionDetail?.fee ?? 0
        networkFee = "\(fee.toAlgos.toAlgosStringForLabel ?? "") ALGO"
        senderAddress = transaction.signerAccount?.name ?? transaction.signerAccount?.address
        //TODO: Warning message will be set here
        assetIcon = account?.type.image(for: .orange)
    }
}
