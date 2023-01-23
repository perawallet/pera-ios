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

//   WebImportErrorViewModel.swift

import Foundation
import MacaroonUIKit

struct WebImportErrorViewModel: ResultViewModel {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var body: EditText?

    init() {
        bindIcon()
        bindTitle()
        bindBody()
    }
}

extension WebImportErrorViewModel {
    private mutating func bindIcon() {
        icon = "icon-error-close"
    }

    private mutating func bindTitle() {
        title = .attributedString("title-generic-error".localized.titleMedium())
    }

    private mutating func bindBody() {
        body = .attributedString("web-import-error-body".localized.bodyRegular())
    }
}
