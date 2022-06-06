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

//   ManagementItemViewModel.swift

import Foundation
import MacaroonUIKit

struct ManagementItemViewModel: ViewModel {
    private(set) var title: EditText?
    private(set) var primaryButton: ButtonViewModel?
    private(set) var secondaryButton: ButtonViewModel?

    init(
        _ type: ManagementItemType
    ) {
        bindTitle(type)
        bindPrimaryButton(type)
        bindSecondaryButton(type)
    }
}

extension ManagementItemViewModel {
    private mutating func bindTitle(
        _ type: ManagementItemType
    ) {
        switch type {
        case .account:
            self.title = .attributedString(
                "accounts-title"
                    .localized
                    .bodyMedium(
                        lineBreakMode: .byTruncatingTail,
                        hasMultilines: false
                    )
            )
        case .asset:
            self.title = .attributedString(
                "accounts-title-assets"
                    .localized
                    .bodyMedium(
                        lineBreakMode: .byTruncatingTail,
                        hasMultilines: false
                    )
            )
        }
    }

    private mutating func bindPrimaryButton(
        _ type: ManagementItemType
    ) {
        switch type {
        case .account:
            self.primaryButton = ButtonCommonViewModel(
                title: "options-sort-title".localized,
                iconSet: [.normal("icon-management-sort")]
            )
        case .asset:
            self.primaryButton = ButtonCommonViewModel(
                title: "asset-manage-button".localized,
                iconSet: [.normal("icon-asset-manage")]
            )
        }
    }

    private mutating func bindSecondaryButton(
        _ type: ManagementItemType
    ) {
        self.secondaryButton = ButtonCommonViewModel(
            title: nil,
            iconSet: [.normal("icon-management-add")]
        )
    }
}

enum ManagementItemType {
    case asset
    case account
}
