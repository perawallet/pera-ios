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

//   WCSessionConnectionProfileView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCSessionConnectionProfileView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .didTapLink: TargetActionInteraction(),
    ]

    private lazy var networkTitleView = UIView()
    private lazy var networkTitleLabel = UILabel()
    private lazy var iconView = URLImageView()
    private lazy var titleView = UILabel()
    private lazy var linkView = MacaroonUIKit.Button(.imageAtLeft(spacing: 12))

    func customize(_ theme: WCSessionConnectionProfileViewTheme) {
        addNetworkTitle(theme)
        addIcon(theme)
        addTitle(theme)
        addLink(theme)
    }

    func bindData(_ viewModel: WCSessionConnectionProfileViewModel?) {
        iconView.load(from: viewModel?.icon)

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }
        
        if let networkTitle = viewModel?.networkTitle {
            networkTitle.load(in: networkTitleLabel)
        } else {
            networkTitleLabel.text = nil
            networkTitleLabel.attributedText = nil
        }

        if let link = viewModel?.link {
            linkView.customizeAppearance(link)
        } else {
            linkView.resetAppearance()
        }
    }

    static func calculatePreferredSize(
        _ viewModel: WCSessionConnectionProfileViewModel?,
        for theme: WCSessionConnectionProfileViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let maxContextSize = CGSize((width, .greatestFiniteMagnitude))
        let networkTitleHeight = theme.networkViewHeight
        let iconSize = theme.iconSize
        let titleSize = viewModel.title?.boundingSize(
            multiline: true,
            fittingSize: maxContextSize
        ) ?? .zero
        let linkTitleSize = viewModel.link?.title?.text.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ) ?? .zero
        let linkIconSize = viewModel.link?.icon?[.normal]?.size ?? .zero
        let linkSize = max(linkTitleSize.height, linkIconSize.height)
        let preferredHeight =
            networkTitleHeight +
            theme.spacingBetweenIconAndTitle +
            iconSize.h +
            theme.spacingBetweenIconAndTitle +
            titleSize.height +
            theme.spacingBetweenTitleAndLink +
            linkSize
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func prepareForReuse() {
        iconView.prepareForReuse()
        titleView.clearText()
        networkTitleLabel.clearText()
        linkView.resetAppearance()
    }
}

extension WCSessionConnectionProfileView {
    private func addNetworkTitle(_ theme: WCSessionConnectionProfileViewTheme) {
        networkTitleLabel.customizeAppearance(theme.networkTitle)
        
        networkTitleView.addSubview(networkTitleLabel)
        networkTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(theme.networkViewInsets.top)
            $0.bottom.equalToSuperview().inset(theme.networkViewInsets.bottom)
            $0.leading.equalToSuperview().offset(theme.networkViewInsets.leading)
            $0.trailing.equalToSuperview().inset(theme.networkViewInsets.trailing)
        }

        networkTitleView.customizeAppearance(theme.networkView)
        networkTitleView.layer.cornerRadius = theme.networkViewCornerRadius
        
        addSubview(networkTitleView)
        networkTitleView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.greaterThanOrEqualTo(theme.networkViewHeight)
        }
    }
    
    private func addIcon(_ theme: WCSessionConnectionProfileViewTheme) {
        iconView.build(theme.icon)

        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.top.equalTo(networkTitleView.snp.bottom).offset(theme.spacingBetweenIconAndTitle)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(theme.iconSize.w)
            $0.height.equalTo(theme.iconSize.h)
        }
    }

    private func addTitle(_ theme: WCSessionConnectionProfileViewTheme) {
        titleView.customizeAppearance(theme.title)
        titleView.numberOfLines = 2
        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == iconView.snp.bottom + theme.spacingBetweenIconAndTitle
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addLink(_ theme: WCSessionConnectionProfileViewTheme) {
        addSubview(linkView)
        linkView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndLink
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        startPublishing(
            event: .didTapLink,
            for: linkView
        )
    }
}

extension WCSessionConnectionProfileView {
    enum Event {
        case didTapLink
    }
}
