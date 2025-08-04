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

//
//   SettingsHeaderViewModel.swift

import MacaroonUIKit

final class SingleGrayTitleHeaderViewModel: ViewModel {
    
    let title: String
    
    init(_ name: String) {
        self.title = name
    }
}

extension SingleGrayTitleHeaderViewModel: Hashable {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title)
    }
    
    static func == (
        lhs: SingleGrayTitleHeaderViewModel,
        rhs: SingleGrayTitleHeaderViewModel
    ) -> Bool {
        return lhs.title == rhs.title
    }
}
