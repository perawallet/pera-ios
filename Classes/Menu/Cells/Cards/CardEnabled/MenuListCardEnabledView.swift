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

protocol MenuListCardEnabledViewDelegate: AnyObject {
    func didPressViewCardsButton(in view: MenuListCardEnabledView)
    func didPressCardDetailButton(in view: MenuListCardEnabledView)
}

final class MenuListCardEnabledView:
    UIView,
    ViewComposable,
    ListReusable {

    private lazy var icon = UIImageView()
    private lazy var title = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var cardView = MacaroonUIKit.Button()
    private lazy var cardViewNumber = UILabel()
    private lazy var cardViewBalance = UILabel()
    private lazy var actionView = MacaroonUIKit.Button()
    private lazy var separator = UIView()
    
    weak var delegate: MenuListCardEnabledViewDelegate?
    
    func customize(_ theme: MenuListCardEnabledViewTheme) {
        addBackground(theme)
        addIcon(theme)
        addTitle(theme)
        addDescription(theme)
        addSeparator(theme)
        addCardView(theme)
        addAction(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ option: MenuOption, viewModel: MenuCardViewModel) {
        icon.image = option.icon
        option.title.load(in: title)
        viewModel.cardNumber.load(in: cardViewNumber)
        viewModel.cardBalance.load(in: cardViewBalance)
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
    
    private func addSeparator(_ theme: MenuListCardEnabledViewTheme) {
        separator.backgroundColor = Colors.Separator.grayLighter.uiColor.withAlphaComponent(0.2)
        
        addSubview(separator)
        separator.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(theme.separatorBottomPadding)
            $0.height.equalTo(theme.separatorHeight)
        }
    }
    
    private func addCardView(_ theme: MenuListCardEnabledViewTheme) {
        addCardViewContent(theme)
        
        addSubview(cardView)
        cardView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.cardViewPaddings.leading)
            $0.trailing.equalToSuperview().inset(theme.cardViewPaddings.trailing)
            $0.top == descriptionLabel.snp.bottom + theme.cardViewPaddings.top
            $0.bottom == separator.snp.top - theme.cardViewPaddings.bottom
        }
        
        cardView.addTarget(self, action: #selector(cardViewTapped), for: .touchUpInside)
    }
    
    private func addCardViewContent(_ theme: MenuListCardEnabledViewTheme) {
        let cardImage = UIImageView()
        cardImage.customizeAppearance(theme.cardView)
        
        cardView.addSubview(cardImage)
        cardImage.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        let arrow = UIImageView()
        arrow.customizeAppearance(theme.arrow)
        
        cardView.addSubview(arrow)
        arrow.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        cardViewNumber.customizeAppearance(theme.cardNumber)
        cardViewBalance.customizeAppearance(theme.cardBalance)
        let stackView = UIStackView(arrangedSubviews: [cardViewNumber, cardViewBalance])
        stackView.axis = .vertical
        stackView.spacing = 0
        
        cardView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading == cardImage.snp.trailing + theme.iconHorizontalPadding
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
    
    @objc private func cardViewTapped() {
        delegate?.didPressCardDetailButton(in: self)
    }
    
    @objc private func actionTapped() {
        delegate?.didPressViewCardsButton(in: self)
    }
}
