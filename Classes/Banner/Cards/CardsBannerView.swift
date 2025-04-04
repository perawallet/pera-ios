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
    private lazy var closeActionView = MacaroonUIKit.Button()
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
            theme.spacingBetweenSubtitleAndAction +
            theme.actionEdgeInsets.top +
            actionSize.height +
            theme.actionEdgeInsets.bottom +
            theme.contentPaddings.bottom
        // TODO: fix height
        return CGSize((size.width, 188))
    }
}

extension CardsBannerView {
    private func addContent(_ theme: CardsBannerTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        addTitle(theme)
        addSubtitle(theme)
        addImage(theme)
        addAction(theme)
        addCloseAction(theme)
    }

    private func addTitle(_ theme: CardsBannerTheme) {
        titleView.customizeAppearance(theme.title)
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading
            $0.trailing == contentView.snp.trailing - theme.titleTrailingMargin
            $0.height.equalTo(theme.titleHeight)
        }
    }
    
    private func addSubtitle(_ theme: CardsBannerTheme) {
        subtitleView.customizeAppearance(theme.subtitle)
        contentView.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndSubtitle
            $0.leading == theme.contentPaddings.leading
            $0.trailing == contentView.snp.trailing - theme.subtitleTrailingMargin
            $0.height.equalTo(theme.subtitleHeight)
        }
    }

    private func addImage(_ theme: CardsBannerTheme) {
        imageView.customizeAppearance(theme.image)

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }

    private func addAction(_ theme: CardsBannerTheme) {
        actionView.customizeAppearance(theme.action)
        actionView.draw(corner: theme.actionCorner)
        
        contentView.addSubview(actionView)
        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        actionView.fitToIntrinsicSize()
        actionView.snp.makeConstraints {
            $0.top == subtitleView.snp.bottom + theme.spacingBetweenSubtitleAndAction
            $0.leading == theme.contentPaddings.leading
            $0.bottom <= theme.contentPaddings.bottom
            $0.trailing <= theme.contentPaddings.trailing
        }

        startPublishing(
            event: .performTryCards,
            for: actionView
        )
    }
    
    private func addCloseAction(_ theme: CardsBannerTheme) {
        closeActionView.customizeAppearance(theme.closeAction)
        closeActionView.draw(corner: theme.closeActionCorner)
        contentView.addSubview(closeActionView)
        
        closeActionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.closeActionPadding)
            $0.trailing.equalToSuperview().inset(theme.closeActionPadding)
            $0.width.equalTo(theme.closeActionWidth)
            $0.height.equalTo(theme.closeActionWidth)
        }

        startPublishing(
            event: .performHideBanner,
            for: closeActionView
        )
    }
}

extension CardsBannerView {
    enum Event {
        case performTryCards
        case performHideBanner
    }
}
