// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CardsBannerView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CardsBannerView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performTryCards: TargetActionInteraction(),
        .performHideBanner: TargetActionInteraction()
    ]

    private lazy var contentView = UIView()
    private lazy var titleView = UILabel()
    private lazy var subtitleView = UILabel()
    private lazy var actionView = MacaroonUIKit.Button()
    private lazy var imageView = UIImageView()

    func customize(_ theme: CardsBannerTheme) {
        customizeAppearance(theme.background)
        draw(corner: theme.corner)

        addContent(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet ) {}

    func bindData(_ viewModel: CardsBannerViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.clearText()
        }

        if let subtitle = viewModel?.subtitle {
            subtitle.load(in: subtitleView)
        } else {
            subtitleView.clearText()
        }

        imageView.image = viewModel?.image?.uiImage
        actionView.editTitle = viewModel?.action
    }

    class func calculatePreferredSize(
        _ viewModel: CardsBannerViewModel?,
        for theme: CardsBannerTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width =
            size.width -
            theme.contentPaddings.leading -
            theme.contentPaddings.trailing
        let titleSize = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let subtitleSize = viewModel.subtitle?.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let actionSize = viewModel.action?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let preferredHeight =
            theme.contentPaddings.top +
            titleSize.height +
            theme.spacingBetweenTitleAndSubtitle +
            subtitleSize.height +
            theme.spacingBetweenContextAndAction +
            theme.actionEdgeInsets.top +
            actionSize.height +
            theme.actionEdgeInsets.bottom +
            theme.contentPaddings.bottom
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CardsBannerView {
    private func addContent(_ theme: CardsBannerTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading
            $0.trailing == theme.contentPaddings.trailing
            $0.bottom == theme.contentPaddings.bottom
        }
        contentView.backgroundColor = .orange
//        addContext(theme)
        addTitle(theme)
        addSubtitle(theme)
        addImage(theme)
        addAction(theme)
    }

//    private func addContext(_ theme: CardsBannerTheme) {
//        contentView.addSubview(contextView)
//        contextView.backgroundColor = .orange
//        contextView.snp.makeConstraints {
//            $0.top == 0
//            $0.leading == 0
//        }
//
//        addTitle(theme)
//        addSubtitle(theme)
//    }

    private func addTitle(_ theme: CardsBannerTheme) {
        titleView.customizeAppearance(theme.title)
        titleView.backgroundColor = .cyan
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == contentView.snp.top
            $0.leading == contentView.snp.leading
            $0.trailing == contentView.snp.trailing - 42
            $0.height == 28
        }
    }
    
    private func addSubtitle(_ theme: CardsBannerTheme) {
        subtitleView.customizeAppearance(theme.subtitle)
        subtitleView.backgroundColor = .green
        contentView.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + 12
            $0.leading == contentView.snp.leading + 24
            $0.trailing == contentView.snp.trailing - 100
        }
    }

    private func addImage(_ theme: CardsBannerTheme) {
        imageView.customizeAppearance(theme.image)

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.bottom.equalTo(contentView.safeAreaBottom)
            $0.trailing.equalTo(contentView.snp.trailingMargin)
        }
    }

    private func addAction(_ theme: CardsBannerTheme) {
        actionView.customizeAppearance(theme.action)
        actionView.draw(corner: theme.actionCorner)

        contentView.addSubview(actionView)
        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        actionView.fitToIntrinsicSize()
        actionView.snp.makeConstraints {
            $0.top == contentView.snp.bottom + theme.spacingBetweenContextAndAction
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        startPublishing(
            event: .performTryCards,
            for: actionView
        )
    }
}

extension CardsBannerView {
    enum Event {
        case performTryCards
        case performHideBanner
    }
}
