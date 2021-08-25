// Copyright 2019 Algorand, Inc.

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
//   BannerView.swift

import Foundation
import Macaroon
import UIKit

final class BannerView: View, ViewModelBindable {
    var completion: (() -> Void)? {
        didSet {
            addBannerTapGesture()
        }
    }

    private var style: Style?

    private lazy var horizontalStackView = UIStackView()
    private lazy var verticalStackView = VStackView()
    private lazy var titleLabel = Label()
    private lazy var messageLabel = Label()
    private lazy var iconView = UIImageView()

    func customize(for style: Style) {
        self.style = style

        customizeAppearance()
        prepareLayout(BannerViewCommonTheme())
    }

    func customizeAppearance() {
        switch style {
        case .info:
            let theme = BannerViewInfoTheme()
            customizeTitleAppearance(theme.title)
            customizeAppearance(theme.background)
            drawAppearance(shadow: theme.backgroundShadow)
        case .error:
            let theme = BannerViewErrorTheme()
            customizeTitleAppearance(theme.title)
            customizeMessageAppearance(theme.message)
            customizeIconAppearance(theme.icon)
            customizeAppearance(theme.background)
            drawAppearance(shadow: theme.backgroundShadow)
        case .none:
            return
        }
    }

    func prepareLayout(_ theme: BannerViewCommonTheme) {
        addHorizontalStackView(theme)

        switch style {
        case .info:
            addVerticalStackView(theme)
            addTitle(theme)
        case .error:
            addIcon(theme)
            addVerticalStackView(theme)
            addTitle(theme)
            addMessage(theme)
        case .none:
            return
        }
    }

    func bindData(_ viewModel: BannerViewModel?) {
        bindTitle(viewModel)
        bindMessage(viewModel)
        bindIcon(viewModel)
    }
}

extension BannerView {
    private func addBannerTapGesture() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBanner)))
    }

    @objc
    private func didTapBanner() {
        completion?()
    }
}

extension BannerView {
    private func customizeTitleAppearance(_ textStyle: TextStyle) {
        titleLabel.customizeAppearance(textStyle)
    }

    private func customizeMessageAppearance(_ messageStyle: TextStyle) {
        messageLabel.customizeAppearance(messageStyle)
    }

    private func customizeIconAppearance(_ imageStyle: ImageStyle) {
        iconView.customizeAppearance(imageStyle)
    }
}

extension BannerView {
    private func addHorizontalStackView(_ theme: BannerViewCommonTheme) {
        addSubview(horizontalStackView)

        horizontalStackView.spacing = theme.horizontalStackViewSpacing
        horizontalStackView.distribution = .fillProportionally
        horizontalStackView.alignment = .top

        horizontalStackView.snp.makeConstraints {
            $0.setPaddings(
                theme.horizontalStackViewPaddings
            )
        }
    }

    private func addVerticalStackView(_ theme: BannerViewCommonTheme) {
        horizontalStackView.addArrangedSubview(verticalStackView)

        verticalStackView.spacing = theme.verticalStackViewSpacing
    }

    private func addTitle(_ theme: BannerViewCommonTheme) {
        verticalStackView.addArrangedSubview(titleLabel)
    }

    private func addMessage(_ theme: BannerViewCommonTheme) {
        verticalStackView.addArrangedSubview(messageLabel)
    }

    private func addIcon(_ theme: BannerViewCommonTheme) {
        horizontalStackView.addArrangedSubview(iconView)
        
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
        }
    }
}

extension BannerView {
    private func bindTitle(_ viewModel: BannerViewModel?) {
        titleLabel.editText = viewModel?.title
    }
    
    private func bindMessage(_ viewModel: BannerViewModel?) {
        messageLabel.editText = viewModel?.message
    }

    private func bindIcon(_ viewModel: BannerViewModel?) {
        iconView.image = viewModel?.icon?.image
    }
}

extension BannerView {
    enum Style {
        case info
        case error
    }
}
