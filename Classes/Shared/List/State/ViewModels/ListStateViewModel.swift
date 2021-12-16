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

import MacaroonUIKit

final class ListStateViewModel: ViewModel {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var detail: EditText?
    private(set) var actionTitle: EditText?

    init() {
        bindIcon()
        bindTitle()
        bindDetail()
        bindActionTitle()
    }
}

extension ListStateViewModel {
    private func bindIcon() {

    }

    private func bindTitle() {

    }

    private func bindDetail() {

    }

    private func bindActionTitle() {

    }
}
