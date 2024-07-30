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

//   IncomingASAAccountView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class IncomingASAAccountView:
    View,
    ViewModelBindable,
    ListReusable {
    
    private lazy var iconView = ImageView()
    private lazy var titleView = UILabel()
    private lazy var primaryAccessoryView = Label()

    func customize(
        _ theme: IncomingASAAccountViewTheme
    ) {
        addIcon(theme)
        addTitle(theme)
        addPrimaryAccessory(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: IncomingASAAccountCellViewModel?
    ) {
        iconView.load(from: viewModel?.icon)
        
        if let address = viewModel?.title {
            address.load(in: titleView)
        }
        
        if let primaryAccessory = viewModel?.primaryAccessory {
            primaryAccessory.load(in: primaryAccessoryView)
        }
        
    }

    class func calculatePreferredSize(
        _ viewModel: IncomingASAAccountCellViewModel?,
        for theme: IncomingASAAccountViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let iconSize = viewModel.icon?.iconSize ?? .zero
        
        let titleSize = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        
        let primaryAccessorySize = viewModel.primaryAccessory?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero

        let contentHeight = titleSize.height
        let preferredHeight = max(iconSize.height, max(contentHeight, primaryAccessorySize.height))

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension IncomingASAAccountView {
    
    private func addIcon(
        _ theme: IncomingASAAccountViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == 0
            $0.fitToSize(theme.iconSize)
        }
    }

    
    private func addTitle(
        _ theme: IncomingASAAccountViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        
        titleView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        titleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.horizontalPadding
            $0.bottom == 0
            $0.trailing <= 0
        }
    }
    
    private func addPrimaryAccessory(
        _ theme: IncomingASAAccountViewTheme
    ) {
        primaryAccessoryView.customizeAppearance(theme.primaryAccessory)

        addSubview(primaryAccessoryView)
        
        primaryAccessoryView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        primaryAccessoryView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        primaryAccessoryView.contentEdgeInsets.leading = theme.horizontalPadding
        primaryAccessoryView.snp.makeConstraints {
            $0.trailing == 0
            $0.leading == titleView.snp.trailing + theme.horizontalPadding
            $0.centerY == 0
        }
    }
}
