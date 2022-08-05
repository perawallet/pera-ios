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

//   SecondaryListItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SecondaryListItemView:
    MacaroonUIKit.View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performAccessory: TargetActionInteraction()
    ]

    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var titleView = UILabel()
    private lazy var accessoryView = SecondaryListItemValueView()

    private var theme: SecondaryListItemViewTheme?

    func customize(
        _ theme: SecondaryListItemViewTheme
    ) {
        self.theme = theme

        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: SecondaryListItemViewModel?
    ) {
        viewModel?.title?.load(in: titleView)

        accessoryView.icon = viewModel?.accessory?.icon
        accessoryView.title = viewModel?.accessory?.title
        /// <todo>: Remove this, it is only for debugging purposes.
        _ = Self.calculatePreferredSize(
            viewModel,
            for: theme!,
            fittingIn:  CGSize((UIScreen.main.bounds.width, .greatestFiniteMagnitude))
        )
    }

    class func calculatePreferredSize(
        _ viewModel: SecondaryListItemViewModel?,
        for theme: SecondaryListItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width

        let contentWidth =
            width
            - theme.contentEdgeInsets.leading
            - theme.contentEdgeInsets.trailing

        let accessoryMaxWidth =
            (contentWidth - theme.minimumSpacingBetweenTitleAndAccessory) * (1 - theme.titleMinimumWidthRatio)

        let accessoryIconSize = viewModel.accessory?.icon?.uiImage.size ?? .zero
        let accessoryIconOffset =
            accessoryIconSize != .zero
            ? theme.accessory.iconLayoutOffset.x
            : .zero

        let accessoryTitleMaxWidth =
            accessoryMaxWidth
            - accessoryIconSize.width
            - accessoryIconOffset
            - theme.accessory.contentEdgeInsets.leading
            - theme.accessory.contentEdgeInsets.trailing

        let accessoryTitleSize = viewModel.accessory?.title.boundingSize(
            multiline: theme.accessory.supportsMultiline,
            fittingSize: CGSize((accessoryTitleMaxWidth, .greatestFiniteMagnitude))
        ) ?? .zero

        let accessoryTitleEstimatedLineHeight: CGFloat = 30

        let titleSize: CGSize

        let isAccessoryTitleMultiline = accessoryTitleSize.height > accessoryTitleEstimatedLineHeight
        if isAccessoryTitleMultiline {
            let titleMaxWidth = (contentWidth - theme.minimumSpacingBetweenTitleAndAccessory) *  theme.titleMinimumWidthRatio

            titleSize = viewModel.title?.boundingSize(
                multiline: theme.titleSupportsMultiline,
                fittingSize: CGSize((titleMaxWidth, .greatestFiniteMagnitude))
            ) ?? .zero
        } else {
            let accessorySize =
                accessoryTitleSize.width +
                accessoryIconSize.width +
                accessoryIconOffset +
                theme.accessory.contentEdgeInsets.leading +
                theme.accessory.contentEdgeInsets.trailing
            let titleMaxWidth =
                contentWidth -
                accessorySize -
                theme.minimumSpacingBetweenTitleAndAccessory

            titleSize = viewModel.title?.boundingSize(
                multiline: theme.titleSupportsMultiline,
                fittingSize: CGSize((titleMaxWidth, .greatestFiniteMagnitude))
            ) ?? .zero
        }

        let accessoryHeight =
            theme.accessory.contentEdgeInsets.top +
            max(accessoryIconSize.height, accessoryTitleSize.height) +
            theme.accessory.contentEdgeInsets.bottom

        let preferredHeight =
            theme.contentEdgeInsets.top +
            max(titleSize.height, accessoryHeight) +
            theme.contentEdgeInsets.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension SecondaryListItemView {
    private func addContent(
        _ theme: SecondaryListItemViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.setPaddings(theme.contentEdgeInsets)
        }

        addTitle(theme)
        addAccessory(theme)
    }

    private func addTitle(
        _ theme: SecondaryListItemViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)

        titleView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .defaultLow
        )

        titleView.snp.makeConstraints {
            $0.width >=
            (contentView.snp.width - theme.minimumSpacingBetweenTitleAndAccessory) * theme.titleMinimumWidthRatio
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addAccessory(
        _ theme: SecondaryListItemViewTheme
    ) {
        accessoryView.customize(theme.accessory)

        contentView.addSubview(accessoryView)
        accessoryView.snp.makeConstraints {
            $0.centerY == 0
            $0.top >= 0
            $0.leading >= titleView.snp.trailing + theme.minimumSpacingBetweenTitleAndAccessory
            $0.bottom <= 0
            $0.trailing == 0
        }

        startPublishing(
            event: .performAccessory,
            for: accessoryView
        )
    }
}

extension SecondaryListItemView {
    enum Event {
        case performAccessory
    }
}
