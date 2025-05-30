// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SecuredByPaymentOptionsViewModel.swift

import Foundation
import MacaroonUIKit

struct SecuredByPaymentOptionsViewModel: ViewModel {
    var icon: Image?
    var title: TextProvider?
    var options: [PaymentOption]?

    init(_ options: [PaymentOption]?) {
        bindIcon()
        bindTitle()

        self.options = options
    }
}

extension SecuredByPaymentOptionsViewModel {
    mutating func bindIcon() {
        icon = "icon-payment-security"
    }

    mutating func bindTitle() {
        title =
        String(localized: "moonpay-introduction-security")
            .bodyMedium(lineBreakMode: .byTruncatingTail)
    }
}
