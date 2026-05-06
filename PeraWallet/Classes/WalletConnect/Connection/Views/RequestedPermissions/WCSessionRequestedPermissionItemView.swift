// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCSessionRequestedPermissionItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCSessionRequestedPermissionItemView:
    MacaroonUIKit.View,
    ViewModelBindable,
    ListReusable {

    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var titleView = UILabel()
    private lazy var rowsStackView = VStackView()

    private var theme: WCSessionRequestedPermissionItemViewTheme?

    func customize(
        _ theme: WCSessionRequestedPermissionItemViewTheme
    ) {
        self.theme = theme
        addContent(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: WCSessionRequestedPermissionViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        rowsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let theme else { return }
        viewModel?.rows.forEach { rowsStackView.addArrangedSubview(makeRowView($0, theme: theme)) }
    }
    
    private func makeRowView(_ row: TextProvider, theme: WCSessionRequestedPermissionItemViewTheme) -> UIView {
        let rowView = HStackView()
        rowView.alignment = .top
        rowView.spacing = theme.spacingBetweenRowIconAndTitle

        let iconView = UIImageView()
        iconView.customizeAppearance(theme.rowIcon)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.rowIconSize)
        }

        let label = UILabel()
        label.customizeAppearance(theme.row)
        row.load(in: label)

        rowView.addArrangedSubview(iconView)
        rowView.addArrangedSubview(label)
        return rowView
    }


    func prepareForReuse() {
        titleView.clearText()
        rowsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}

extension WCSessionRequestedPermissionItemView {
    private func addContent(_ theme: WCSessionRequestedPermissionItemViewTheme) {
        contentView.customizeAppearance(theme.content)
        contentView.layer.cornerRadius = 16

        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.setPaddings(theme.contentPaddings)
        }

        addTitle(theme)
        addRows(theme)
    }

    private func addTitle(_ theme: WCSessionRequestedPermissionItemViewTheme) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
    }

    private func addRows(_ theme: WCSessionRequestedPermissionItemViewTheme) {
        rowsStackView.spacing = theme.spacingBetweenTitleAndRows

        contentView.addSubview(rowsStackView)
        rowsStackView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndRows
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.bottom == theme.contentEdgeInsets.bottom
        }
    }
}
