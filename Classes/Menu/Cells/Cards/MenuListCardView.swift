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

//   MenuListCardView.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

protocol MenuListCardViewDelegate: AnyObject {
    func didPressActionButton(in view: MenuListCardView)
}

final class MenuListCardView:
    UIView,
    ViewComposable,
    ListReusable {

    private lazy var icon = UIImageView()
    private lazy var title = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var image = UIImageView()
    private lazy var actionView = MacaroonUIKit.Button()
    private lazy var notSupportedCountryTitleLabel = UILabel()
    private lazy var notSupportedCountryTextLabel = UILabel()
    
    weak var delegate: MenuListCardViewDelegate?
    
    func customize(_ theme: MenuListCardViewTheme) {
        addBackground(theme)
        addIcon(theme)
        addTitle(theme)
        addDescription(theme)
        addNotSupportedCountryInformation(theme)
        addImage(theme)
        addAction(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ option: MenuOption, theme: MenuListCardViewTheme) {
        icon.image = option.icon
        option.title.load(in: title)
        option.description.load(in: descriptionLabel)
        switch option {
        case .cards(state: let state):
            switch state {
            case .inactive:
                actionView.semanticContentAttribute = .unspecified
                actionView.customizeAppearance(theme.actionInactive)
                actionView.titleEdgeInsets = theme.actionInactiveTitleEdgeInsets
                actionView.imageEdgeInsets = theme.actionInactiveImageEdgeInsets
                notSupportedCountryTitleLabel.isHidden = true
                notSupportedCountryTextLabel.isHidden = true
            case .active:
                actionView.semanticContentAttribute = .forceRightToLeft
                actionView.customizeAppearance(theme.actionActive)
                actionView.titleEdgeInsets = theme.actionActiveTitleEdgeInsets
                actionView.imageEdgeInsets = theme.actionActiveImageEdgeInsets
                notSupportedCountryTitleLabel.isHidden = true
                notSupportedCountryTextLabel.isHidden = true
            case .notSupported(userCountryName: let userCountryName):
                actionView.isHidden = true
                descriptionLabel.isHidden = true
                notSupportedCountryTextLabel.text = String(format: String(localized: "cards-not-supported-country-text"), userCountryName)
            }
        default:
            break
        }
    }

    func prepareForReuse() {
        icon.image = nil
        title.clearText()
    }
}

extension MenuListCardView {
    private func addBackground(_ theme: MenuListCardViewTheme) {
        customizeAppearance(theme.background)
        layer.cornerRadius = theme.contentViewRadius
    }
    
    private func addIcon(_ theme: MenuListCardViewTheme) {
        addSubview(icon)
        icon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.iconHorizontalPadding)
            $0.top.equalToSuperview().inset(theme.iconVerticalPadding)
        }
    }

    private func addTitle(_ theme: MenuListCardViewTheme) {
        title.customizeAppearance(theme.title)

        addSubview(title)
        title.snp.makeConstraints {
            $0.leading == icon.snp.trailing + theme.titleHorizontalPadding
            $0.centerY.equalTo(icon.snp.centerY)
        }
    }
    
    private func addDescription(_ theme: MenuListCardViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)
        descriptionLabel.numberOfLines = 0

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.iconHorizontalPadding)
            $0.top == title.snp.bottom + theme.spaceBetweenTitleAndDescription
        }
    }
    
    private func addNotSupportedCountryInformation(_ theme: MenuListCardViewTheme) {
        notSupportedCountryTitleLabel.customizeAppearance(theme.notSupportedCountryTitle)
        notSupportedCountryTextLabel.customizeAppearance(theme.notSupportedCountryText)
        notSupportedCountryTextLabel.numberOfLines = 0

        addSubview(notSupportedCountryTitleLabel)
        notSupportedCountryTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.iconHorizontalPadding)
            $0.top == title.snp.bottom + theme.spaceBetweenTitleAndDescription
        }
        
        addSubview(notSupportedCountryTextLabel)
        notSupportedCountryTextLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.iconHorizontalPadding)
            $0.trailing.equalToSuperview().inset(theme.notSupportedCountryTextPadding)
            $0.top == notSupportedCountryTitleLabel.snp.bottom + theme.iconVerticalPadding
        }
    }
    
    private func addImage(_ theme: MenuListCardViewTheme) {
        image.customizeAppearance(theme.image)
        
        addSubview(image)
        image.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.imageVerticalPadding)
        }
    }
    
    private func addAction(_ theme: MenuListCardViewTheme) {
        addSubview(actionView)
        actionView.fitToHorizontalIntrinsicSize()
        
        actionView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.actionPadding)
            $0.bottom.equalToSuperview().inset(theme.actionPadding)
            $0.trailing.equalToSuperview().inset(theme.actionPadding)
            $0.height.equalTo(theme.actionHeight)
        }
        
        actionView.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }
    
    @objc private func actionTapped() {
        delegate?.didPressActionButton(in: self)
    }
}
