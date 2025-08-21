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

//   CarouselBannerItemModel.swift

import UIKit
import pera_wallet_core

struct CarouselBannerItemModel: Hashable {
    let id: Int
    let text: String
    let image: URL?
    let url: URL?
    let buttonUrlIsExternal: Bool
    let isBackupBanner: Bool
    
    init(apiModel: SpotBannerListItem.APIModel) {
        self.id = apiModel.id
        self.text = apiModel.text
        self.image = URL(string: apiModel.image)
        self.url = URL(string: apiModel.url)
        self.buttonUrlIsExternal = apiModel.buttonUrlIsExternal
        self.isBackupBanner = false
    }
    
    init () {
        self.id = 0
        self.text = String(localized: "account-not-backed-up-warning-title")
        self.image = nil
        self.url = nil
        self.buttonUrlIsExternal = false
        self.isBackupBanner = true
    }
}
