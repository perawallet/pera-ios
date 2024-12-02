// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingAsaListItemView.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class IncomingASAListItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var iconView = URLImageView()
    private lazy var loadingIndicatorView = ViewLoadingIndicator()
    private lazy var contentView = UIView()
    private lazy var titleView = IncominASAListTitleView()
    private lazy var valueContentView = UIView()
    private lazy var primaryValueView = UILabel()
    private lazy var secondaryValueView = UILabel()
    
    func customize(
        _ theme: IncomingASAListItemViewTheme
    ) {
        addIcon(theme)
        addContent(theme)
        addTitle(theme)
        addValueContent(theme)
        addPrimaryValue(theme)
        addSecondaryValue(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: IncomingASAListItemViewModel?
    ) {
        if let icon = viewModel?.imageSource {
            iconView.load(from: icon)
        } else {
            iconView.prepareForReuse()
        }

        if let title = viewModel?.title {
            titleView.bindData(title)
        } else {
            titleView.prepareForReuse()
        }

        if let value = viewModel?.primaryValue {
            value.load(in: primaryValueView)
        } else {
            primaryValueView.clearText()
        }

        if let value = viewModel?.secondaryValue {
            value.load(in: secondaryValueView)
        } else {
            secondaryValueView.clearText()
        }
    }

    class func calculatePreferredSize(
        _ viewModel: IncomingASAListItemViewModel?,
        for theme: IncomingASAListItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width

        let titleSize = IncominASAListTitleView.calculatePreferredSize(
            viewModel.title,
            for: theme.title,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        let primaryValueSize = viewModel.primaryValue?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let secondaryValueSize = viewModel.secondaryValue?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let valueContentHeight = primaryValueSize.height + secondaryValueSize.height

        let preferredHeight = max(titleSize.height, valueContentHeight)

        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    func prepareForReuse() {
        iconView.prepareForReuse()
        titleView.prepareForReuse()
        primaryValueView.clearText()
        secondaryValueView.clearText()
    }
}

extension IncomingASAListItemView {
    private func addIcon(
        _ theme: IncomingASAListItemViewTheme
    ) {
        iconView.build(theme.icon)
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.leading == 0
            $0.centerY == 0
        }

        addLoadingIndicator(theme)
    }

    private func addLoadingIndicator(
        _ theme: IncomingASAListItemViewTheme
    ) {
        loadingIndicatorView.applyStyle(theme.loadingIndicator)

        iconView.addSubview(loadingIndicatorView)
        loadingIndicatorView.snp.makeConstraints {
            $0.fitToSize(theme.loadingIndicatorSize)
            $0.center.equalToSuperview()
        }

        loadingIndicatorView.isHidden = true
    }

    private func addContent(
        _ theme: IncomingASAListItemViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.contentHorizontalPadding
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addTitle(
        _ theme: IncomingASAListItemViewTheme
    ) {
        titleView.customize(theme.title)
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.width >= (contentView - theme.minSpacingBetweenTitleAndValue) * theme.contentMinWidthRatio
            $0.top >= 0
            $0.leading == 0
            $0.bottom <= 0
            $0.centerY == 0
        }
    }

    private func addValueContent(
        _ theme: IncomingASAListItemViewTheme
    ) {
        contentView.addSubview(valueContentView)
        valueContentView.snp.makeConstraints {
            $0.top >= 0
            $0.leading >= titleView.snp.trailing + theme.minSpacingBetweenTitleAndValue
            $0.bottom <= 0
            $0.trailing == 0
            $0.centerY == 0
        }
    }

    private func addPrimaryValue(
        _ theme: IncomingASAListItemViewTheme
    ) {
        primaryValueView.customizeAppearance(theme.primaryValue)
        primaryValueView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        primaryValueView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )

        valueContentView.addSubview(primaryValueView)
        primaryValueView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addSecondaryValue(
        _ theme: IncomingASAListItemViewTheme
    ) {
        secondaryValueView.customizeAppearance(theme.secondaryValue)
        secondaryValueView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        secondaryValueView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        
        valueContentView.addSubview(secondaryValueView)
        secondaryValueView.snp.makeConstraints {
            $0.top == primaryValueView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension IncomingASAListItemView {
    var isLoading: Bool {
        return loadingIndicatorView.isAnimating
    }
    
    func startLoading() {
        loadingIndicatorView.isHidden = false

        loadingIndicatorView.startAnimating()
    }

    func stopLoading() {
        loadingIndicatorView.isHidden = true

        loadingIndicatorView.stopAnimating()
    }
}
