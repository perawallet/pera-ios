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

//   GroupedListItemButton.swift

import Foundation
import MacaroonUIKit
import UIKit

final class GroupedListItemButton:
    View,
    ViewModelBindable {
    private lazy var titleView = Label()
    private lazy var contentView = VStackView()

    func customize(
        _ theme: GroupedListItemButtonTheme
    ) {
        addTitle(theme)
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: GroupedListItemButtonViewModel?
    ) {
        guard let viewModel = viewModel else {
            return
        }

        if let title = viewModel.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        contentView.deleteAllArrangedSubviews()
        viewModel.listItemButtons.forEach {
            addButton($0)
        }
    }
}

extension GroupedListItemButton {
    private func addTitle(
         _ theme: GroupedListItemButtonTheme
     ) {
         titleView.customizeAppearance(theme.title)

         addSubview(titleView)
         titleView.fitToVerticalIntrinsicSize()
         titleView.contentEdgeInsets.bottom = theme.spacingBetweenTitleAndContent
         titleView.snp.makeConstraints {
             $0.top == 0
             $0.leading == 0
             $0.trailing <= 0
         }
     }

    private func addContent(
        _ theme: GroupedListItemButtonTheme
    ) {
        addSubview(contentView)
        contentView.spacing = theme.spacingBetweenActions
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentPaddings.top + theme.contentSafeAreaInsets.top,
            leading: theme.contentPaddings.leading + theme.contentSafeAreaInsets.left,
            bottom: theme.contentPaddings.bottom + theme.contentSafeAreaInsets.bottom,
            trailing: theme.contentPaddings.trailing + theme.contentSafeAreaInsets.right
        )
        contentView.insetsLayoutMarginsFromSafeArea = false
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.fitToVerticalIntrinsicSize(
             hugging: .defaultLow,
             compression: .required
         )
        contentView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension GroupedListItemButton {
    private func addButton(
        _ button: ListItemButton
    ) {
        contentView.addArrangedSubview(button)
    }
}
