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

//   SelectAccountNoContentViewModel.swift

import Foundation
import MacaroonUIKit

struct SelectAccountNoContentViewModel:
    NoContentViewModel,
    Hashable {
    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?

    init() {
        bindIcon()
        bindTitle()
        bindBody()
    }
}

extension SelectAccountNoContentViewModel {
    private mutating func bindIcon() {
         icon = "img-accounts-empty"
    }
    
    private mutating func bindTitle() {
        title = String(localized: "empty-accounts-title")
            .bodyLargeMedium(
                alignment: .center
            )
    }
    
    private mutating func bindBody() {
        body = String(localized: "empty-accounts-detail")
            .bodyRegular(
                alignment: .center
            )
    }
}

extension SelectAccountNoContentViewModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title?.string)
        hasher.combine(body?.string)
    }
    
    static func == (
        lhs: SelectAccountNoContentViewModel,
        rhs: SelectAccountNoContentViewModel
    ) -> Bool {
        return
            lhs.title?.string == rhs.title?.string &&
            lhs.body?.string == rhs.body?.string
    }
}
