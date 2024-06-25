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

//   IncomingASAAccountInboxHeaderTitleCellViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct IncomingASAAccountInboxHeaderTitleCellViewModel:
    TitleViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var titleStyle: TextStyle?

    init(count: Int) {
        bind(count: count)
    }
}

extension IncomingASAAccountInboxHeaderTitleCellViewModel {
    mutating func bind(count: Int) {
        bindTitle(count: count)
        bindTitleStyle()
    }

    mutating func bindTitle(count: Int) {
        if count == 1 {
            title = .attributedString(
                "incoming-asa-account-inbox-header-title-cell-singular"
                    .localized
                    .footnoteRegular()
            )
            return
        }
        
        title = .attributedString(
            "incoming-asa-account-inbox-header-title-cell"
                .localized(params: "\(count)")
                .footnoteRegular()
        )
    }

    mutating func bindTitleStyle() {
        titleStyle = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
    }
}
