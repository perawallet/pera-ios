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

//   CarouselBannerItemView.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class CarouselBannerItemView:
    UIView,
    ViewComposable,
    ListReusable {
    
    weak var delegate: CarouselBannerDelegate?
    private var banner: CarouselBannerItemModel?
    
    private lazy var iconView = UIImageView()
    private lazy var textLabel = UILabel()
    private lazy var arrowView = UIView()
    private lazy var closeButton = Button()
    
    func customize(_ theme: CarouselBannerItemViewTheme) {
        addBackground(theme)
        addIcon(theme)
        addText(theme)
        addArrow(theme)
        addCloseButton(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func bindData(_ banner: CarouselBannerItemModel) {
        prepareForReuse()
        textLabel.text = banner.text
        if banner.isBackupBanner {
            textLabel.textColor = Colors.Helpers.negative.uiColor
            iconView.backgroundColor = Colors.Helpers.negativeLighter.uiColor
            let icon = UIImageView(image: UIImage(named: "icon-backup-banner"))
            iconView.addSubview(icon)
            icon.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        } else {
            iconView.kf.setImage(with: banner.image)
        }
        arrowView.isHidden = !banner.isBackupBanner
        closeButton.isHidden = banner.isBackupBanner
        self.banner = banner
    }
    
    func prepareForReuse() {
        iconView.image = nil
        iconView.removeAllSubviews()
        textLabel.clearText()
        textLabel.textColor = Colors.Text.main.uiColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            layer.borderColor = Colors.Layer.gray.uiColor.cgColor
        }
    }
}

extension CarouselBannerItemView {
    private func addBackground(_ theme: CarouselBannerItemViewTheme) {
        customizeAppearance(theme.background)
        layer.cornerRadius = theme.contentViewRadius
        layer.borderWidth = 1
        layer.borderColor = Colors.Layer.gray.uiColor.cgColor
    }
    
    private func addIcon(_ theme: CarouselBannerItemViewTheme) {
        iconView.layer.cornerRadius = theme.iconViewHeight / 2
        iconView.clipsToBounds = true
        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.width.equalTo(theme.iconViewHeight)
            $0.height.equalTo(theme.iconViewHeight)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.contentHorizontalPadding)
        }
    }
    
    private func addText(_ theme: CarouselBannerItemViewTheme) {
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
    
    private func addArrow(_ theme: CarouselBannerItemViewTheme) {
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
    
    private func addCloseButton(_ theme: CarouselBannerItemViewTheme) {
        closeButton.customizeAppearance(theme.closeButton)
        closeButton.layer.cornerRadius = theme.closeButtonHeight / 2
        closeButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.width.equalTo(theme.closeButtonHeight)
            $0.height.equalTo(theme.closeButtonHeight)
            $0.top.equalToSuperview().inset(theme.closeButtonPadding)
            $0.trailing.equalToSuperview().inset(theme.closeButtonPadding)
        }
    }
    
    @objc private func buttonTapped() {
        delegate?.didTapCloseButton(in: banner)
    }
}
