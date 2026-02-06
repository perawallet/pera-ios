// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   AccountListItemView.swift

import MacaroonUIKit
import UIKit

final class AccountListItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var iconView = ImageView()
    private lazy var iconBottomRightBadgeView = UIImageView()
    
    private var iconBottomRightTextBadgeShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        return view
    }()
    
    private var iconBottomRightTextBadgeView: UILabel = {
        let view = UILabel()
        view.font = Fonts.DMSans.bold.make(13.0).uiFont
        view.textColor = .Wallet.wallet1Icon
        view.textAlignment = .center
        view.backgroundColor = .Defaults.bg
        view.clipsToBounds = true
        view.layer.cornerRadius = 12.0
        view.layer.borderWidth = 0.2
        view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        return view
    }()
    
    private lazy var contentAndAccessoryContextView = UIView()
    private lazy var contentView = UIView()
    private lazy var titleView = PrimaryTitleView()
    private lazy var accessoryView = UIView()
    private lazy var primaryAccessoryView = Label()
    private lazy var secondaryAccessoryView = Label()
    private lazy var accessoryIconView = ImageView()

    func customize(
        _ theme: PrimaryAccountListItemViewTheme
    ) {
        addIcon(theme)
        addContentAndAccessoryContext(theme)
        addAccessoryIcon(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: AccountListItemViewModel?
    ) {
        iconView.load(from: viewModel?.icon)
        
        switch viewModel?.badge {
        case let .image(image):
            iconBottomRightBadgeView.image = image
            iconBottomRightTextBadgeView.isHidden = true
        case let .text(text):
            iconBottomRightTextBadgeView.text = text
            iconBottomRightTextBadgeView.isHidden = false
        case .none:
            iconBottomRightBadgeView.image = nil
            iconBottomRightTextBadgeView.text = nil
            iconBottomRightTextBadgeView.isHidden = true
        }
        
        titleView.bindData(viewModel?.title)
        primaryAccessoryView.editText = viewModel?.primaryAccessory
        secondaryAccessoryView.editText = viewModel?.secondaryAccessory
        accessoryIconView.image = viewModel?.accessoryIcon
    }

    class func calculatePreferredSize(
        _ viewModel: AccountListItemViewModel?,
        for theme: PrimaryAccountListItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        /// <warning>
        /// The constrained widths of the subviews will be discarded from the calculations because
        /// none of them has the multi-line texts.
        let width = size.width
        let iconSize = viewModel.icon?.iconSize ?? .zero
        let titleSize = PrimaryTitleView.calculatePreferredSize(
            viewModel.title,
            for: theme.title,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        let primaryAccessorySize = viewModel.primaryAccessory.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let secondaryAccessorySize = viewModel.secondaryAccessory.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let accessoryIconSize = viewModel.accessoryIcon?.size ?? .zero
        let contentHeight = titleSize.height
        let accessoryTextHeight = primaryAccessorySize.height + secondaryAccessorySize.height
        let accessoryHeight = max(accessoryTextHeight, accessoryIconSize.height)
        let preferredHeight = max(iconSize.height, max(contentHeight, accessoryHeight))
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AccountListItemView {
    private func addIcon(
        _ theme: PrimaryAccountListItemViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == 0
            $0.fitToSize(theme.iconSize)
        }

        addIconBottomRightBadge(theme)
    }

    private func addIconBottomRightBadge(
        _ theme: PrimaryAccountListItemViewTheme
    ) {
        addSubview(iconBottomRightBadgeView)
        iconBottomRightBadgeView.snp.makeConstraints {
            $0.top == iconView.snp.top + theme.iconBottomRightBadgePaddings.top
            $0.leading == theme.iconBottomRightBadgePaddings.leading
        }
        
        
        addSubview(iconBottomRightTextBadgeShadowView)
        iconBottomRightTextBadgeShadowView.addSubview(iconBottomRightTextBadgeView)
        
        iconBottomRightTextBadgeShadowView.snp.makeConstraints {
            $0.top == iconView.snp.top + theme.iconBottomRightBadgePaddings.top
            $0.leading == theme.iconBottomRightBadgePaddings.leading
            $0.width.height.equalTo(24.0)
        }
        
        iconBottomRightTextBadgeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addContentAndAccessoryContext(
        _ theme: PrimaryAccountListItemViewTheme
    ) {
        addSubview(contentAndAccessoryContextView)
        contentAndAccessoryContextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.horizontalPadding
            $0.bottom == 0
        }

        addContent(theme)
        addAccessory(theme)
    }

    private func addContent(
        _ theme: PrimaryAccountListItemViewTheme
    ) {
        contentAndAccessoryContextView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width >= contentAndAccessoryContextView * theme.contentMinWidthRatio
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }

        addTitle(theme)
    }

    private func addTitle(
        _ theme: PrimaryAccountListItemViewTheme
    ) {
        titleView.customize(theme.title)

        contentView.addSubview(titleView)
        
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
    }

    private func addAccessory(
        _ theme: PrimaryAccountListItemViewTheme
    ) {
        contentAndAccessoryContextView.addSubview(accessoryView)
        accessoryView.snp.makeConstraints {
            $0.top == 0
            $0.leading == contentView.snp.trailing
            $0.bottom == 0
            $0.trailing == 0
        }

        addPrimaryAccessory(theme)
        addSecondaryAccessory(theme)
    }

    private func addPrimaryAccessory(
        _ theme: PrimaryAccountListItemViewTheme
    ) {
        primaryAccessoryView.customizeAppearance(theme.primaryAccessory)

        accessoryView.addSubview(primaryAccessoryView)

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
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
            $0.bottom
                .equalToSuperview()
                .priority(.low)
        }
    }

    private func addSecondaryAccessory(
        _ theme: PrimaryAccountListItemViewTheme
    ) {
        secondaryAccessoryView.customizeAppearance(theme.secondaryAccessory)

        accessoryView.addSubview(secondaryAccessoryView)

        secondaryAccessoryView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        secondaryAccessoryView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .defaultLow
        )

        secondaryAccessoryView.contentEdgeInsets.leading = theme.horizontalPadding
        secondaryAccessoryView.snp.makeConstraints {
            $0.top == primaryAccessoryView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addAccessoryIcon(
        _ theme: PrimaryAccountListItemViewTheme
    ) {
        accessoryIconView.customizeAppearance(theme.accessoryIcon)

        addSubview(accessoryIconView)
        accessoryIconView.contentEdgeInsets = theme.accessoryIconContentEdgeInsets
        accessoryIconView.fitToIntrinsicSize()
        accessoryIconView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == contentAndAccessoryContextView.snp.trailing
            $0.trailing == 0
        }
    }
}
