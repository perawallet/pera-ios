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

//   SecondaryListItemViewModel.swift

import Foundation
import MacaroonUIKit

protocol SecondaryListItemViewModel: ViewModel {
    var title: TextProvider? { get }
    var accessory: ButtonStyle? { get }
}

extension SecondaryListItemViewModel {
    func getTitle(
        title: String,
        textColor: Color = AppColors.Components.Text.gray
    ) -> TextProvider {
        var attributes: TextAttributeGroup = .bodyRegular(
            lineBreakMode: .byTruncatingTail
        )

        attributes.insert(.textColor(textColor))

        return title.attributed(
            attributes
        )
    }

    func getNonInteractableAccessory(
        title: String,
        titleColor: Color = AppColors.Components.Text.main
    ) -> ButtonStyle {
        return [
            .title(getNonInteractableAccessoryTitle(title)),
            .titleColor([ .normal(titleColor) ] ),
            .isInteractable(false)
        ]
    }

    func getNonInteractableAccessory(
        icon: Image,
        title: String,
        titleColor: Color = AppColors.Components.Text.main
    ) -> ButtonStyle {
        return [
            .title(getNonInteractableAccessoryTitle(title)),
            .icon([ .normal(icon) ]),
            .titleColor([ .normal(titleColor) ] ),
            .isInteractable(false)
        ]
    }

    private func getNonInteractableAccessoryTitle(
        _ title: String
    ) -> EditText {
        return .attributedString(
            title
                .bodyRegular(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }

    func getInteractableAccessory(
        title: String,
        titleColor: Color = AppColors.Shared.Helpers.positive
    ) -> ButtonStyle {
        return [
            .title(getInteractableAccessoryTitle(title)),
            .titleColor([ .normal(titleColor), .highlighted(titleColor) ] ),
        ]
    }

    func getInteractableAccessory(
        icon: Image,
        title: String,
        titleColor: Color = AppColors.Shared.Helpers.positive
    ) -> ButtonStyle {
        return [
            .title(getInteractableAccessoryTitle(title)),
            .icon([ .normal(icon), .highlighted(icon) ]),
            .titleColor([ .normal(titleColor), .highlighted(titleColor) ] ),
        ]
    }

    private func getInteractableAccessoryTitle(
        _ title: String
    ) -> EditText {
        return .attributedString(
            title
                .bodyMedium(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }
}
