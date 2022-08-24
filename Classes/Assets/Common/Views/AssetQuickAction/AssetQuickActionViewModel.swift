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

//   AssetQuickActionViewModel.swift

import Foundation
import MacaroonUIKit

final class AssetQuickActionViewModel {
    private(set) var title: EditText?
    private(set) var titleTopPadding: LayoutMetric?
    
    private(set) var accountTypeImage: ImageStyle?

    private(set) var accountName: EditText?

    private(set) var buttonTitleColor: Color?
    private(set) var buttonBackgroundColor: Color?
    private(set) var buttonIcon: Image?
    private(set) var buttonTitle: EditText?

    private(set) var buttonFirstShadow: MacaroonUIKit.Shadow?
    private(set) var buttonSecondShadow: MacaroonUIKit.Shadow?
    private(set) var buttonThirdShadow: MacaroonUIKit.Shadow?

    init(type: ActionType) {
        switch type {
        case .addAssetWithoutAccount:
            bindTitle(type)
            bindButton(type)
            return
        case .addAsset(let account),
                .optIn(let account),
                .removeCollectible(let account):
            bindTitle(type)
            bindButton(type)
            bindAccountTypeImage(account)
            bindAccountName(account)
        }
    }
}

extension AssetQuickActionViewModel {
    private func bindTitle(_ type: ActionType) {
        switch type {
        case .optIn:
            self.title = .attributedString(
                "asset-quick-action-title-opt-in"
                    .localized
                    .footnoteRegular()
            )
        case .addAsset:
            self.title = .attributedString(
                "asset-quick-action-title-add"
                    .localized
                    .footnoteRegular()
            )
        case .addAssetWithoutAccount:
            self.title = .attributedString(
                "asset-quick-action-title-add-without-account"
                    .localized
                    .footnoteRegular()
            )
            self.titleTopPadding = 26
        case .removeCollectible:
            self.title = .attributedString(
                "asset-quick-action-title-remove"
                    .localized
                    .footnoteRegular()
            )
        }
    }

    private func bindAccountTypeImage(_ account: Account) {
        self.accountTypeImage = [
            .image(account.typeImage),
            .isInteractable(false)
        ]
    }

    private func bindAccountName(_ account: Account) {
        self.accountName = .attributedString(
            (account.name ?? account.address.shortAddressDisplay).footnoteRegular()
        )
    }

    private func bindButton(_ actionType: ActionType) {
        switch actionType {
        case .optIn:
            self.buttonIcon = img("icon-quick-action-plus")
            self.buttonTitle = .attributedString(
                "single-transaction-request-opt-in-title"
                    .localized
                    .footnoteMedium()
            )
            self.buttonTitleColor = Colors.Button.Primary.text
            self.buttonBackgroundColor = Colors.Button.Primary.background
        case .addAsset:
            self.buttonIcon = img("icon-quick-action-plus")
            self.buttonTitle = .attributedString(
                "asset-quick-action-button-add"
                    .localized
                    .footnoteMedium()
            )
            self.buttonTitleColor = Colors.Button.Primary.text
            self.buttonBackgroundColor = Colors.Button.Primary.background
        case .addAssetWithoutAccount:
            self.buttonIcon = img("icon-quick-action-plus")
            self.buttonTitle = .attributedString(
                "asset-quick-action-button-add"
                    .localized
                    .footnoteMedium()
            )
            self.buttonTitleColor = Colors.Button.Primary.text
            self.buttonBackgroundColor = Colors.Button.Primary.background
        case .removeCollectible:
            self.buttonIcon = img("icon-quick-action-remove")
            self.buttonTitle = .attributedString(
                "title-remove"
                    .localized
                    .footnoteMedium()
            )
            self.buttonTitleColor = Colors.Helpers.negative
            self.buttonBackgroundColor = Colors.Defaults.background

            bindButtonShadows()
        }
    }

    private func bindButtonShadows() {
        self.buttonFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: Colors.Defaults.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        self.buttonSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: Colors.Defaults.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        self.buttonThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            fillColor: Colors.Defaults.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
    }
}

extension AssetQuickActionViewModel {
    enum ActionType {
        case optIn(with: Account)
        case addAsset(to: Account)
        case addAssetWithoutAccount
        case removeCollectible(from: Account)
    }
}
