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
    UIInteractionObservable,
    UIControlInteractionPublisher,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performAccessory: UIControlInteraction()
    ]

    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var titleView = UILabel()

    private var accessoryLayout: Button.Layout {
        return theme?.accessoryLayout ?? .none
    }

    private lazy var accessoryView = MacaroonUIKit.Button(accessoryLayout)

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

        if let accessory = viewModel?.accessory {
            accessoryView.customizeAppearance(accessory)
        } else {
            accessoryView.resetAppearance()
        }
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

        let titleSize = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero

        let accessoryIconSize = viewModel.accessory?.icon?.first?.uiImage.size ?? .zero
        let accessoryTitleSize = viewModel.accessory?.title?.text.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero

        let accessoryHeight =
        theme.accessoryContentEdgeInsets.top +
        max(accessoryIconSize.height, accessoryTitleSize.height) +
        theme.accessoryContentEdgeInsets.bottom

        let contentHeight =
        theme.contentEdgeInsets.top +
        max(titleSize.height, accessoryHeight) +
        theme.contentEdgeInsets.bottom

        let preferredHeight = contentHeight
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
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
        contentView.addSubview(titleView)

        titleView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .defaultHigh
        )

        titleView.snp.makeConstraints {
            $0.width >= self * theme.titleMinimumWidthRatio
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addAccessory(
        _ theme: SecondaryListItemViewTheme
    ) {
        accessoryView.contentEdgeInsets = UIEdgeInsets(theme.accessoryContentEdgeInsets)
        accessoryView.draw(corner: theme.accessoryCorner)

        contentView.addSubview(accessoryView)
        accessoryView.fitToIntrinsicSize()
        accessoryView.snp.makeConstraints {
            $0.top == 0
            $0.leading >= titleView.snp.trailing + theme.minimumSpacingBetweenTitleAndAccessory
            $0.trailing == 0
            $0.bottom == 0
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
