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

//   WCSessionConnectionDateSecondaryListItemViewModel.swift

import Foundation
import MacaroonUIKit

struct WCSessionConnectionDateSecondaryListItemViewModel: SecondaryListItemViewModel {
    var title: TextProvider?
    var accessory: SecondaryListItemValueViewModel?

    init() {
        bindTitle()
        bindAccessory()
    }
}

extension WCSessionConnectionDateSecondaryListItemViewModel {
    private mutating func bindTitle() {
        title =
            "wc-session-connection-date"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindAccessory() {
        accessory = WCSessionConnectionDateSecondaryListItemValueViewModel()
    }
}

fileprivate struct WCSessionConnectionDateSecondaryListItemValueViewModel: SecondaryListItemValueViewModel {
    var icon: ImageStyle?
    var title: TextProvider?

    init() {
        bindTitle()
    }
}

extension WCSessionConnectionDateSecondaryListItemValueViewModel {
    private mutating func bindTitle() {
        let date = "Apr 8, 2023, 22:10 PM".footnoteRegular(lineBreakMode: .byTruncatingTail)
        let hour = "22:10 PM"

        var hourAttributes = Typography.footnoteRegularAttributes(lineBreakMode: .byTruncatingTail)
        hourAttributes.insert(.textColor(Colors.Text.gray))
                                                                  
        let aTitle = date.addAttributes(
            to: hour,
            newAttributes: hourAttributes
        )
        title = aTitle
    }
}
