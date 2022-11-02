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

//   DiscoveryASAItem.swift

import Foundation

struct DiscoveryASAItem: Hashable {
    let model: DiscoveryASA
    let viewModel: DiscoveryASASearchNameListViewModel

    init(asset: DiscoveryASA) {
        self.model = asset
        self.viewModel = DiscoveryASASearchNameListViewModel(asset: asset)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(model.id)
        hasher.combine(model.name)
        hasher.combine(model.unitName)
    }

    static func == (
        lhs: DiscoveryASAItem,
        rhs: DiscoveryASAItem
    ) -> Bool {
        return
            lhs.model.id == rhs.model.id &&
            lhs.model.name == rhs.model.name &&
            lhs.model.unitName == rhs.model.unitName
    }
}
