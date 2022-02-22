// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ManageAssetsListActionViewModel.swift

import Foundation
import MacaroonUIKit

struct ManageAssetsListActionViewModel: ListActionViewModel {
    let icon: Image?
    let title: EditText?
    let subtitle: EditText?
    
    init() {
        self.icon = "icon-polygon"
        self.title = Self.getTitle("options-manage-assets".localized)
        self.subtitle = nil
    }
}
