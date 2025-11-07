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

//   ASADetailViewControllerLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASADetailViewControllerLoadingView:
    UIView,
    ShimmerAnimationDisplaying,
    UIScrollViewDelegate {
    var animatableSubviews: [ShimmerAnimatable] {
        var subviews: [ShimmerAnimatable] = [
            iconView,
            titleView,
            primaryValueView,
            secondaryValueView
        ]
        subviews += holdingsView.animatableSubviews
        subviews += marketsView.animatableSubviews
        return subviews
    }

    private lazy var profileView = UIView()
    private lazy var iconView = ShimmerView()
    private lazy var titleView = ShimmerView()
    private lazy var primaryValueView = ShimmerView()
    private lazy var secondaryValueView = ShimmerView()
    private lazy var quickActionsView = HStackView()
    private lazy var pageBar = PageBar()
    private lazy var pagesView = UIScrollView()
    private lazy var holdingsContainerView = UIView()
    private lazy var holdingsView = TransactionHistoryLoadingView()
    private lazy var marketsView = ASAAboutLoadingView()

    func customize(_ theme: ASADetailViewControllerLoadingViewTheme) {
        addBackground(theme)
        addPagesFragment(theme)
    }
}

extension ASADetailViewControllerLoadingView {
    private func addBackground(_ theme: ASADetailViewControllerLoadingViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addPagesFragment(_ theme: ASADetailViewControllerLoadingViewTheme) {
        addPageBar(theme)
        addPages(theme)
    }

    private func addPageBar(_ theme: ASADetailViewControllerLoadingViewTheme) {
        pageBar.customizeAppearance(theme.pageBarStyle)
        pageBar.prepareLayout(theme.pageBarLayout)

        addSubview(pageBar)
        pageBar.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        pageBar.items = [
            theme.holdingsPageBarItem,
            theme.marketsPageBarItem
        ]
    }

    private func addPages(_ theme: ASADetailViewControllerLoadingViewTheme) {
        addSubview(pagesView)
        pagesView.bounces = false
        pagesView.showsHorizontalScrollIndicator = false
        pagesView.showsVerticalScrollIndicator = false
        pagesView.isPagingEnabled = true
        pagesView.delegate = self
        pagesView.snp.makeConstraints {
            $0.top == pageBar.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addHoldings(theme)
        addMarkets(theme)
    }

    private func addHoldings(_ theme: ASADetailViewControllerLoadingViewTheme) {
        pagesView.addSubview(holdingsContainerView)
        holdingsContainerView.snp.makeConstraints {
            $0.width == self
            $0.top == 0
            $0.leading == 0
        }

        holdingsView.customize(theme.holdings)
        profileView.customizeAppearance(theme.profile)

        [profileView, holdingsView, quickActionsView].forEach { holdingsContainerView.addSubview($0) }
        
        bindProfile(theme)
        bindQuickActions(theme)
        
        profileView.snp.makeConstraints {
            $0.top == theme.holdingsContentEdgeInsets.top
            $0.leading == theme.holdingsContentEdgeInsets.leading
            $0.trailing == theme.holdingsContentEdgeInsets.trailing
        }
        
        quickActionsView.snp.makeConstraints {
            $0.top == profileView.snp.bottom + theme.holdingsContentEdgeInsets.top
            $0.leading == theme.holdingsContentEdgeInsets.leading
            $0.trailing == theme.holdingsContentEdgeInsets.trailing
        }
        
        holdingsView.snp.makeConstraints {
            $0.top == quickActionsView.snp.bottom + theme.holdingsContentEdgeInsets.top
            $0.leading == theme.holdingsContentEdgeInsets.leading
            $0.bottom == theme.holdingsContentEdgeInsets.bottom
            $0.trailing == theme.holdingsContentEdgeInsets.trailing
        }
    }
    
    private func bindProfile(_ theme: ASADetailViewControllerLoadingViewTheme) {
        addIcon(theme)
        addTitle(theme)
        addPrimaryValue(theme)
        addSecondaryValue(theme)
    }
    
    private func addIcon(_ theme: ASADetailViewControllerLoadingViewTheme) {
        iconView.draw(corner: theme.iconCorner)

        profileView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.top == theme.profileTopEdgeInset
            $0.leading == 0
        }
    }

    private func addTitle(_ theme: ASADetailViewControllerLoadingViewTheme) {
        titleView.draw(corner: theme.corner)

        profileView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.fitToSize(theme.titleSize)
            $0.leading == iconView.snp.trailing + theme.spacingBetweenIconAndTitle
            $0.centerY == iconView.snp.centerY
        }
    }

    private func addPrimaryValue(_ theme: ASADetailViewControllerLoadingViewTheme) {
        primaryValueView.draw(corner: theme.corner)

        profileView.addSubview(primaryValueView)
        primaryValueView.snp.makeConstraints {
            $0.fitToSize(theme.primaryValueSize)
            $0.top == titleView.snp.bottom + theme.spacingBetweenIconAndPrimaryValue
            $0.leading == 0
        }
    }

    private func addSecondaryValue(_ theme: ASADetailViewControllerLoadingViewTheme) {
        secondaryValueView.drawAppearance(corner: theme.corner)

        profileView.addSubview(secondaryValueView)
        secondaryValueView.snp.makeConstraints {
            $0.fitToSize(theme.secondaryValueSize)
            $0.top == primaryValueView.snp.bottom + theme.spacingBetweenPrimaryAndSecondaryValue
            $0.bottom == 0
            $0.leading == 0
        }
    }
    
    private func bindQuickActions(_ theme: ASADetailViewControllerLoadingViewTheme) {
        quickActionsView.distribution = .fillEqually
        quickActionsView.alignment = .top
        quickActionsView.spacing = theme.spacingBetweenQuickActions
        quickActionsView.directionalLayoutMargins = .init(
            top: theme.spacingBetweenProfileAndQuickActions,
            leading: 0,
            bottom: theme.spacingBetweenQuickActionsAndPageBar,
            trailing: 0
        )
        quickActionsView.isLayoutMarginsRelativeArrangement = true

        let backgroundView = UIView()
        backgroundView.customizeAppearance(theme.quickActions)

        quickActionsView.insertSubview(backgroundView, at: 0)
        backgroundView.snp.makeConstraints {
            $0.edges == quickActionsView
        }

        addQuickAction(
            icon: theme.sendActionIcon,
            title: theme.sendActionTitle,
            theme: theme
        )
        addQuickAction(
            icon: theme.receiveActionIcon,
            title: theme.receiveActionTitle,
            theme: theme
        )
    }

    private func addQuickAction(
        icon: Image,
        title: TextProvider,
        theme: ASADetailViewControllerLoadingViewTheme
    ) {
        let view = UIView()
        view.snp.makeConstraints {
            $0.fitToWidth(theme.quickActionWidth)
        }

        let iconView = UIImageView()

        iconView.image = icon.uiImage

        view.addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == 0
            $0.leading >= 0
            $0.trailing <= 0
            $0.centerX == 0
        }

        let titleView = UILabel()

        title.load(in: titleView)

        view.addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == iconView.snp.bottom + theme.spacingBetweenQuickActionIconAndTitle
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        quickActionsView.addArrangedSubview(view)
    }


    private func addMarkets(_ theme: ASADetailViewControllerLoadingViewTheme) {
        marketsView.customize(theme.markets)

        pagesView.addSubview(marketsView)
        marketsView.snp.makeConstraints {
            $0.width == self
            $0.top == 0
            $0.leading == holdingsContainerView.snp.trailing
            $0.trailing == 0
        }
    }
}

/// <mark>
/// UIScrollViewDelegate
extension ASADetailViewControllerLoadingView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageBar.scrollToItem(
            at: scrollView.contentOffset.x - pageBar.frame.minX,
            animated: false
        )
    }
}
