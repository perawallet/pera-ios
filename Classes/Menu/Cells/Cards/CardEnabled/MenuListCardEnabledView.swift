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

//   MenuListCardEnabledView.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class MenuListCardEnabledView:
    UIView,
    ViewComposable,
    ListReusable {

    private lazy var icon = UIImageView()
    private lazy var title = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var actionView = MacaroonUIKit.Button()
    private lazy var separator = UIView()
    
    weak var delegate: MenuListCardViewDelegate?
    
    func customize(_ theme: MenuListCardEnabledViewTheme) {
        addBackground(theme)
        addIcon(theme)
        addTitle(theme)
        addDescription(theme)
        addAction(theme)
        addSeparator(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ option: MenuOption) {
        icon.image = option.icon
        option.title.load(in: title)
        String(localized: "title-recently-used-card").load(in: descriptionLabel)
    }

    func prepareForReuse() {
        icon.image = nil
        title.clearText()
    }
}

extension MenuListCardEnabledView {
    private func addBackground(_ theme: MenuListCardEnabledViewTheme) {
        customizeAppearance(theme.background)
        layer.cornerRadius = theme.contentViewRadius
    }
    
    private func addIcon(_ theme: MenuListCardEnabledViewTheme) {
        addSubview(icon)
        icon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.iconHorizontalPadding)
            $0.top.equalToSuperview().inset(theme.iconVerticalPadding)
        }
    }

    private func addTitle(_ theme: MenuListCardEnabledViewTheme) {
        title.customizeAppearance(theme.title)

        addSubview(title)
        title.snp.makeConstraints {
            $0.leading == icon.snp.trailing + theme.titleHorizontalPadding
            $0.centerY.equalTo(icon.snp.centerY)
        }
    }
    
    private func addDescription(_ theme: MenuListCardEnabledViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.iconHorizontalPadding)
            $0.top == title.snp.bottom + theme.spaceBetweenTitleAndDescription
        }
    }
    
    private func addAction(_ theme: MenuListCardEnabledViewTheme) {
        actionView.customizeAppearance(theme.action)
        
        addSubview(actionView)
        actionView.fitToHorizontalIntrinsicSize()
        
        actionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(theme.actionHeight)
        }
        
        actionView.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }
    
    private func addSeparator(_ theme: MenuListCardEnabledViewTheme) {
        separator.backgroundColor = Colors.Separator.grayLighter.uiColor.withAlphaComponent(0.2)
        addSubview(separator)
        separator.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(56)
            $0.height.equalTo(1)
        }
    }
    
    @objc private func actionTapped() {
//        delegate?.didPressActionButton(in: self)
    }
}
