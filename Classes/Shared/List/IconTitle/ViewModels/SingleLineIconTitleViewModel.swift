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
//   SingleLineIconTitleViewModel.swift

import MacaroonUIKit

final class SingleLineIconTitleViewModel: ViewModel {
    private(set) var icon: Image?
    private(set) var title: EditText?

    init(
        item: SingleLineIconTitleItem
    ) {
        bindIcon(item)
        bindTitle(item)
    }
}

extension SingleLineIconTitleViewModel {
    private func bindIcon(
        _ item: SingleLineIconTitleItem
    ) {
        icon = item.icon
    }

    private func bindTitle(
        _ item: SingleLineIconTitleItem
    ) {
        title = .string(item.title)
    }
}

struct SingleLineIconTitleItem {
    let icon: Image?
    let title: String?
}
