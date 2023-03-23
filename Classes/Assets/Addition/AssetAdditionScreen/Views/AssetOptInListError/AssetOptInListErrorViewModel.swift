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

//   AssetOptInListErrorViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetOptInListErrorViewModel: ViewModel {
    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?

    init(error: AssetListErrorItem) {
        bindIcon()
        bindTitle(error: error)
        bindBody(error: error)
    }
}

extension AssetOptInListErrorViewModel {
    mutating func bindIcon() {
        icon = "icon-info-square".templateImage
    }

    mutating func bindTitle(error: AssetListErrorItem) {
        title = error.title?.bodyMedium(alignment: .center)
    }

    mutating func bindBody(error: AssetListErrorItem) {
        body = error.body?.footnoteRegular(alignment: .center)
    }
}
