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

//   SelectAssetErrorItemViewModel.swift

import Foundation
import MacaroonUIKit

struct SelectAssetErrorItemViewModel:
    NoContentViewModel,
    Hashable {
    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?

    init() {
        bindTitle()
        bindBody()
    }
}

extension SelectAssetErrorItemViewModel {
    mutating func bindTitle() {
        title =
            String(localized: "title-generic-error")
                .bodyLargeMedium(
                    alignment: .center
                )
    }

    mutating func bindBody() {
        body =
            String(localized: "swap-asset-pool-search-error")
                .bodyRegular(
                    alignment: .center
                )
    }
}
