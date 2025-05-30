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

//   WebImportSuccessInfoBoxViewModel.swift

import Foundation
import MacaroonUIKit

struct WebImportSuccessInfoBoxViewModel: InfoBoxViewModel {
    var icon: Image?
    var title: TextProvider?
    var message: TextProvider?
    var style: InfoBoxViewStyle?

    init(unimportedAccountCount: Int) {
        bindIcon()
        bindTitle(unimportedAccountCount: unimportedAccountCount)
        bindMessage(unimportedAccountCount: unimportedAccountCount)
        bindStyle()
    }
}

extension WebImportSuccessInfoBoxViewModel {
    private mutating func bindIcon() {
        icon = "icon-info-positive"
    }

    private mutating func bindTitle(unimportedAccountCount: Int) {
        let isSingular = unimportedAccountCount == 1
        let title = isSingular ? String(localized: "web-import-success-unimported-singular-title") : String(localized: "web-import-success-unimported-title")

        self.title = title.footnoteMedium()
    }

    private mutating func bindMessage(unimportedAccountCount: Int) {
        self.message = String(format: String(localized: "web-import-success-unimported-body"), unimportedAccountCount).footnoteRegular()
    }

    private mutating func bindStyle() {
        style = InfoBoxViewStyle(
            background: [
                .backgroundColor(Colors.Helpers.positiveLighter)
            ],
            corner: Corner(radius: 8)
        )
    }
}
