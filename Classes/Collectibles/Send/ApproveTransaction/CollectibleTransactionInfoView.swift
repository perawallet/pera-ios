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

//   CollectibleTransactionInfoView.swift

import MacaroonUIKit

final class CollectibleTransactionInfoView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var contextView = HStackView()
    private lazy var titleView = Label()
    private lazy var iconView = ImageView()
    private lazy var valueView = Label()

    func customize(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        addContext(theme)
    }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func bindData(
        _ viewModel: CollectibleTransactionInfoViewModel?
    ) {
        titleView.editText = viewModel?.title

        if let icon = viewModel?.icon {
            iconView.image = icon
        } else {
            iconView.isHidden = true
        }

        valueView.editText = viewModel?.value

        if let valueStyle = viewModel?.valueStyle {
            valueView.customizeAppearance(valueStyle)
        }
    }
}

extension CollectibleTransactionInfoView {
    private func addContext(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        addSubview(contextView)
        contextView.spacing = theme.contextViewSpacing

        contextView.snp.makeConstraints {
            $0.setPaddings()
        }

        addTitle(theme)
        addIcon(theme)
        addValue(theme)
    }

    private func addTitle(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        contextView.addArrangedSubview(titleView)

        titleView.snp.makeConstraints {
            $0.width >= self * theme.titleMinimumWidthRatio
        }
    }

    private func addIcon(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        contextView.addArrangedSubview(iconView)
        iconView.fitToIntrinsicSize()

        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
        }
    }

    private func addValue(
        _ theme: CollectibleTransactionInfoViewTheme
    ) {
        valueView.customizeAppearance(theme.value)

        contextView.addArrangedSubview(valueView)
        valueView.fitToIntrinsicSize()
    }
}
