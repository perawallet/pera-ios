// Copyright 2025 Pera Wallet, Lda

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

struct ManagementItemViewModel:
    ViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var primaryButtonTitle: EditText?
    private(set) var primaryButtonIcon: Image?
    private(set) var secondaryButtonTitle: EditText?
    private(set) var secondaryButtonIcon: Image?

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
                String(localized: "title-accounts")
                    .bodyMedium(
                        lineBreakMode: .byTruncatingTail
                    )
            )
        case .asset:
            self.title = .attributedString(
                String(localized: "title-assets")
                    .bodyMedium(
                        lineBreakMode: .byTruncatingTail
                    )
            )
        case .collectible(let count, _):
            self.title = .attributedString(
                String(format: String(localized: "title-plus-collectible-count"), count)
                    .bodyMedium(
                        lineBreakMode: .byTruncatingTail
                    )
            )
        }
    }

    private mutating func bindPrimaryButton(
        _ type: ManagementItemType
    ) {
        switch type {
        case .account:
            self.primaryButtonTitle = .attributedString(
                String(localized: "title-sort")
                    .bodyMedium()
            )
            self.primaryButtonIcon = img("icon-management-sort")
        case .asset,
             .collectible:
            self.primaryButtonTitle = .attributedString(
                String(localized: "asset-manage-button")
                    .bodyMedium()
            )
            self.primaryButtonIcon = img("icon-asset-manage")
        }
    }

    private mutating func bindSecondaryButton(
        _ type: ManagementItemType
    ) {
        switch type {
        case .collectible(_, let isWatchAccountDisplay),
             .asset(let isWatchAccountDisplay):
            if isWatchAccountDisplay {
                return
            }

            fallthrough
        default:
            secondaryButtonTitle = nil
            secondaryButtonIcon = img("icon-management-add")
        }
    }
}

enum ManagementItemType {
    case asset(isWatchAccountDisplay: Bool)
    case account
    case collectible(count: Int, isWatchAccountDisplay: Bool)
}

extension ManagementItemViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title)
    }

    static func == (
        lhs: ManagementItemViewModel,
        rhs: ManagementItemViewModel
    ) -> Bool {
        return lhs.title == rhs.title
    }
}
