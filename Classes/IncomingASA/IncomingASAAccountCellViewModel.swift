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

//   IncomingASAAccountCellViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct IncomingASAAccountCellViewModel: 
    ViewModel,
    Hashable {
    private(set) var address: String?
    private(set) var requestCount: Int?
    private(set) var title: TextProvider?
    private(set) var icon: UIImage?
    private(set) var primaryAccessory: TextProvider?

    init( _ account: Account,
          incomingRequestCount: Int
    ) {
        bind(account, incomingRequestCount: incomingRequestCount)
    }

    static func == (lhs: IncomingASAAccountCellViewModel, rhs: IncomingASAAccountCellViewModel) -> Bool {
        return lhs.address?.string == rhs.address?.string &&
        lhs.title?.string == rhs.title?.string &&
        lhs.requestCount == rhs.requestCount &&
        lhs.icon == rhs.icon &&
        lhs.primaryAccessory?.string == rhs.primaryAccessory?.string
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
        hasher.combine(requestCount)
        hasher.combine(title?.string)
        hasher.combine(icon)
        hasher.combine(primaryAccessory?.string)
    }
}

extension IncomingASAAccountCellViewModel {
    mutating func bind(
        _ model: Account,
        incomingRequestCount: Int
    ) {
        self.address = model.address
        self.requestCount = incomingRequestCount
        bindTitle(incomingRequestCount)
        bindIcon(model)
        bindPrimaryAccessory(model)
    }
}

extension IncomingASAAccountCellViewModel {
    mutating func bindTitle(
        _ requestCount: Int
    ) {
        if requestCount == 1 {
            self.title = "incoming-asa-accounts-screen-cell-title-singular".localized
        } else {
            self.title = "incoming-asa-accounts-screen-cell-title".localized(params: "\(requestCount)")
        }
    }
    
    mutating func bindIcon(
        _ account: Account
    ) {
        icon = account.typeImage
    }
    
    mutating func bindPrimaryAccessory(
        _ account: Account
    ) {
        primaryAccessory = account.name ?? account.address.shortAddressDisplay
    }
}
