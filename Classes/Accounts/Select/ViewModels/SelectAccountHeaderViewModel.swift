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
//   SelectAccountHeaderViewModel.swift


import Foundation
import UIKit
import MacaroonUIKit

final class SelectAccountHeaderViewModel: PairedViewModel {
    private let mode: SelectAccountHeaderMode

    var title: String {
        get {
            switch self.mode {
            case .accounts:
                return "account-select-header-accounts-title".localized
            case .contacts:
                return "account-select-header-contacts-title".localized
            }
        }
    }

    init(_ model: SelectAccountHeaderMode) {
        self.mode = model
    }
}

enum SelectAccountHeaderMode {
    case accounts
    case contacts
}
