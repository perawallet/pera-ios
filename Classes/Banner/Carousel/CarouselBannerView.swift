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

//   CarouselBannerView.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class CarouselBannerView:
    UIView,
    ViewComposable,
    ListReusable {

    private lazy var icon = UIImageView()
    private lazy var iconView = UIView()
    private lazy var textLabel = UILabel()
    private lazy var arrowView = UIView()
    
    func customize(_ theme: CarouselBannerViewTheme) {
        addBackground(theme)
        addIcon(theme)
        addText(theme)
        addArrow(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ banner: CarouselBanner) {
        icon.image = banner.icon
        iconView.backgroundColor = banner.iconBackground
        textLabel.text = banner.title
        if banner == .backup {
            textLabel.textColor = Colors.Helpers.negative.uiColor
        }
        arrowView.isHidden = !banner.showNavigationButton
    }

    func prepareForReuse() {
        icon.image = nil
        textLabel.clearText()
    }
}

extension CarouselBannerView {
    private func addBackground(_ theme: CarouselBannerViewTheme) {
        customizeAppearance(theme.background)
        layer.cornerRadius = theme.contentViewRadius
        layer.borderWidth = 1
        layer.borderColor = Colors.Layer.gray.uiColor.cgColor
    }
    
    private func addIcon(_ theme: CarouselBannerViewTheme) {
        iconView.layer.cornerRadius = theme.iconViewHeight / 2
        iconView.addSubview(icon)
        icon.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.width.equalTo(theme.iconViewHeight)
            $0.height.equalTo(theme.iconViewHeight)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.contentHorizontalPadding)
        }
    }

    private func addText(_ theme: CarouselBannerViewTheme) {
        textLabel.customizeAppearance(theme.text)
        textLabel.numberOfLines = 0
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.leading == iconView.snp.trailing + theme.spacingBetweenTextAndIcon
            $0.centerY.equalToSuperview()
            $0.height.equalTo(theme.textHeight)
            $0.trailing.equalToSuperview().inset(theme.textHorizontalPadding)
        }
    }
    
    private func addArrow(_ theme: CarouselBannerViewTheme) {
        arrowView.customizeAppearance(theme.arrowView)
        arrowView.layer.cornerRadius = theme.arrowViewHeight / 2
        
        let arrow = UIImageView()
        arrow.customizeAppearance(theme.arrow)
        
        arrowView.addSubview(arrow)
        arrow.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        addSubview(arrowView)
        arrowView.snp.makeConstraints {
            $0.width.equalTo(theme.arrowViewHeight)
            $0.height.equalTo(theme.arrowViewHeight)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(theme.contentHorizontalPadding)
        }
    }
}
