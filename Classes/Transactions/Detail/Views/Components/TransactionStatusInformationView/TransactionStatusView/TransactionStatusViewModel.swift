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
//   TransactionStatusViewModel.swift

import Foundation
import MacaroonUIKit

final class TransactionStatusViewModel: ViewModel {
    private(set) var status: Transaction.Status
    private(set) var statusLabelTitle: String?
    private(set) var statusLabelTextColor: Color?
    private(set) var backgroundColor: Color?

    init(_ status: Transaction.Status) {
        self.status = status
        bindStatus(status)
    }
}

extension TransactionStatusViewModel {
    func bindStatus(_ status: Transaction.Status) {
        switch status {
        case .completed:
            statusLabelTitle = "transaction-detail-completed".localized
            statusLabelTextColor = Colors.Helpers.positive
            backgroundColor = Colors.Helpers.positive.uiColor.withAlphaComponent(0.1)
        case .pending:
            statusLabelTitle = "transaction-detail-pending".localized
            statusLabelTextColor = Colors.Text.gray
        case .failed:
            statusLabelTitle = "transaction-detail-failed".localized
            statusLabelTextColor = Colors.Helpers.negative
            backgroundColor = Colors.Helpers.negative.uiColor.withAlphaComponent(0.1)
        }
    }
}
