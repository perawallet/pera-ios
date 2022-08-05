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
import UIKit

protocol SecondaryListItemViewModel: ViewModel {
    var title: TextProvider? { get }

    typealias Accessory = (icon: Image?, title: TextProvider)
    var accessory: Accessory? { get }
}

extension SecondaryListItemViewModel {
    func getTitle(
        title: String,
        titleColor: Color = AppColors.Components.Text.gray,
        titleLineBreakMode: NSLineBreakMode = .byWordWrapping
    ) -> TextProvider {
        var attributes = Typography.bodyRegularAttributes(
            lineBreakMode: titleLineBreakMode
        )

        attributes.insert(.textColor(titleColor))

        return title.attributed(
            attributes
        )
    }

    func getInteractableAccessory(
        icon: Image? = nil,
        title: String,
        titleColor: Color = AppColors.Shared.Helpers.positive,
        titleLineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) -> Accessory {
        return Accessory(
            icon: icon,
            title: getInteractableAccessoryTitle(
                title: title,
                titleColor: titleColor,
                titleLineBreakMode: titleLineBreakMode
            )
        )
    }

    func getInteractableAccessoryTitle(
        title: String,
        titleColor: Color = AppColors.Shared.Helpers.positive,
        titleLineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) -> TextProvider {
        var attributes = Typography.bodyMediumAttributes(
            lineBreakMode: titleLineBreakMode
        )

        attributes.insert(.textColor(titleColor))

        return title.attributed(
            attributes
        )
    }

    func getNonInteractableAccessory(
        icon: Image? = nil,
        title: String,
        titleColor: Color = AppColors.Components.Text.main,
        titleLineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) -> Accessory {
        return Accessory(
            icon: icon,
            title: getNonInteractableAccessoryTitle(
                title: title,
                titleColor: titleColor,
                titleLineBreakMode: titleLineBreakMode
            )
        )
    }

    func getNonInteractableAccessoryTitle(
        title: String,
        titleColor: Color = AppColors.Components.Text.main,
        titleLineBreakMode: NSLineBreakMode
    ) -> TextProvider {
        var attributes = Typography.bodyRegularAttributes(
            lineBreakMode: titleLineBreakMode
        )

        attributes.insert(.textColor(titleColor))

        return title.attributed(
            attributes
        )
    }
}
