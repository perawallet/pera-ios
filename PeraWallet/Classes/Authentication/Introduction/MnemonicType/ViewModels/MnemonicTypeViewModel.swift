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

//   MnemonicTypeViewModel.swift

import UIKit
import MacaroonUIKit
import Foundation
import pera_wallet_core

struct MnemonicTypeViewModel: ViewModel {
    private(set) var image: UIImage?
    private(set) var title: TextProvider?
    private(set) var detail: TextProvider?
    private(set) var info: TextProvider?
    private(set) var isRecommended: TextProvider?
  
    init(
        title: String,
        detail: String,
        info: String,
        isRecommended: Bool
    ) {
        self.image = img("icon-circle-arrow-right")
        self.title = title
        bindDetail(detail: detail)
        self.info = info
        bindRecommendation(isRecommended)
    }
    
    private mutating func bindDetail(detail: String) {
        self.detail = detail.attributed(
            Typography.footnoteRegularAttributes(
                alignment: .left,
                lineBreakMode: .byTruncatingTail
            )
        )
    }

    
    private mutating func bindRecommendation(
        _ isRecommended: Bool
    ) {
        self.isRecommended = isRecommended ? String(localized: "title-new-uppercased") : String(localized: "title-legacy-uppercased")
    }
}
