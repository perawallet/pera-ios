// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   TransactionError.swift

import UIKit

enum TransactionError: Error, Hashable {
    case minimumAmount(amount: UInt64)
    case invalidAddress(address: String)
    case sdkError(error: NSError?)
    case draft(draft: TransactionSendDraft?)
    case ledgerConnection
    case optOutFromCreator
    case other
}

extension TransactionError {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .minimumAmount: hasher.combine(0)
        case .invalidAddress: hasher.combine(1)
        case .sdkError: hasher.combine(2)
        case .draft: hasher.combine(3)
        case .ledgerConnection: hasher.combine(4)
        case .optOutFromCreator: hasher.combine(5)
        case .other: hasher.combine(6)
        }
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        switch (lhs, rhs) {
        case (.minimumAmount, .minimumAmount): return true
        case (.invalidAddress, .invalidAddress): return true
        case (.sdkError, .sdkError): return true
        case (.draft, .draft): return true
        case (.ledgerConnection, .ledgerConnection): return true
        case (.other, .other): return true
        default: return false
        }
    }
}
