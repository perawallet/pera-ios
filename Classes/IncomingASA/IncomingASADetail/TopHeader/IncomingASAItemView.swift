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

//   IncomingASAItemView.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class IncomingASAItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var iconView = URLImageView()
    private lazy var loadingIndicatorView = ViewLoadingIndicator()
    private lazy var contentView = UIView()
    private lazy var titleView = IncomingASAItemTitleView()
    private lazy var valueContentView = UIView()
    private lazy var primaryValueView = UILabel()
    private var isCollectible: Bool = false
    
    func customize(
        _ theme: IncomingASAItemViewTheme
    ) {
        addIcon(theme)
        addContent(theme)
        addTitle(theme)
        addValueContent(theme)
        addPrimaryValue(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: IncomingASAListItem?
    ) {
        
        let asaItem = viewModel?.itemViewModel
        
        if let collectibleViewModel = viewModel?.collectibleViewModel {
            iconView.load(from: collectibleViewModel.icon)
            isCollectible = true
        } else {
            if let icon = asaItem?.imageSource {
                iconView.load(from: icon)
            } else {
                iconView.prepareForReuse()
            }
        }
        
        if let title = asaItem?.title {
            titleView.bindData(title)
        } else {
            titleView.prepareForReuse()
        }
        
        if viewModel?.collectibleViewModel != nil {
            if let value = viewModel?.senders?.count {
                let count = "\(value)"
                count.load(in: primaryValueView)
            } else {
                primaryValueView.clearText()
            }
        } else {
            if let value = asaItem?.title?.primaryTitle {
                value.load(in: primaryValueView)
            } else {
                primaryValueView.clearText()
            }
        }
    }
    
    class func calculatePreferredSize(
        _ viewModel: IncomingASAItemViewModel?,
        for theme: IncomingASAItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let titleSize = CGSize((width, .greatestFiniteMagnitude))
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
    }
}

extension IncomingASAItemView {
    private func addIcon(
        _ theme: IncomingASAItemViewTheme
    ) {
        iconView.build(theme.icon)
        iconView.customizeAppearance(theme.icon)
        if isCollectible {
            iconView.draw(corner: theme.nftIconCorner)
        }
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
        _ theme: IncomingASAItemViewTheme
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
        _ theme: IncomingASAItemViewTheme
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
        _ theme: IncomingASAItemViewTheme
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
        _ theme: IncomingASAItemViewTheme
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
        _ theme: IncomingASAItemViewTheme
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
            $0.top == titleView.snp.top
            $0.trailing == 0
        }
    }
}

extension IncomingASAItemView {
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
