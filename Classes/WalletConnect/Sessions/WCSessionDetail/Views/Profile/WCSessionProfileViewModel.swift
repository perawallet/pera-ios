// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCSessionProfileViewModel.swift

import Foundation
import MacaroonUIKit

struct WCSessionProfileViewModel: ViewModel {
    private(set) var icon: ImageSource?
    private(set) var title: TextProvider?
    private(set) var link: TextProvider?
    private(set) var description: TextProvider?

    init() {
        bindIcon()
        bindTitle()
        bindLink()
        bindDescription()
    }
}

extension WCSessionProfileViewModel {
    private mutating func bindIcon() {
        icon = "icon-wallet".uiImage
    }

    private mutating func bindTitle() {
        title =
            "AlgoVerify"
                .bodyLargeMedium(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindLink() {
        link =
            "www.algoverify.me"
                .footnoteMedium(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindDescription() {
        description =
            "AlgoVerify is a verification system for Algorand projects."
                .footnoteRegular()
    }
}
