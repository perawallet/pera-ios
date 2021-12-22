// Copyright 2019 Algorand, Inc.

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
//   ListStateViewModel.swift

import UIKit
import MacaroonUIKit

final class ListStateViewModel: ViewModel {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var detail: EditText?
    private(set) var actionTitle: EditText?

    init(_ model: ListStateDraft) {
        bindIcon(model)
        bindTitle(model)
        bindDetail(model)
        bindActionTitle(model)
    }
}

extension ListStateViewModel {
    private func bindIcon(
        _ model: ListStateDraft
    ) {
        icon = model.icon
    }

    private func bindTitle(
        _ model: ListStateDraft
    ) {
        title = .string(model.title)
    }

    private func bindDetail(
        _ model: ListStateDraft
    ) {
        detail = .string(model.detail)
    }

    private func bindActionTitle(
        _ model: ListStateDraft
    ) {
        actionTitle = .string(model.actionTitle)
    }
}

struct ListStateDraft {
    let icon: UIImage?
    let title: String
    let detail: String
    let actionTitle: String?
}
