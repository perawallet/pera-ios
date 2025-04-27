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

//   IncomingASAsDetailLoadingScreenViewModel.swift

import MacaroonUIKit
import UIKit

struct IncomingASAsDetailLoadingScreenViewModel: LoadingScreenViewModel {
    
    private(set) var imageName: String?
    private(set) var title: TextProvider?
    private(set) var detail: TextProvider?

    init() {
        bindImageName()
        bindTitle()
        bindDetail()
    }
}

extension IncomingASAsDetailLoadingScreenViewModel {
    mutating func bindImageName() {
        imageName = "pera_loader_240x240"
    }

    mutating func bindTitle() {
        title = String(localized: "sending-transaction-loading-title")
            .bodyLargeMedium(alignment: .center)
    }

    mutating func bindDetail() {
        detail = String(localized: "incoming-asas-detail-loading-detail")
            .bodyRegular(alignment: .center)
    }
}
