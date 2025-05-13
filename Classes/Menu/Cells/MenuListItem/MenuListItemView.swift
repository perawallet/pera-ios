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

//   MenuListItemView.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class MenuListItemView:
    UIView,
    ViewComposable,
    ListReusable {

    private lazy var icon = UIImageView()
    private lazy var title = UILabel()
    private lazy var arrow = UIImageView()
    private lazy var nftsView = UIView()
    private lazy var newLabel = UILabel()
    private lazy var nftImage1 = UIImageView()
    private lazy var nftImage2 = UIImageView()
    private lazy var nftImage3 = UIImageView()
    
    func customize(_ theme: MenuListItemViewTheme) {
        addBackground(theme)
        addIcon(theme)
        addTitle(theme)
        addArrow(theme)
        addNFTsView(theme)
        addNewLabel(theme)

    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ option: MenuOption) {
        icon.image = option.icon
        option.title.load(in: title)
        newLabel.isHidden = !option.showNewLabel
        nftsView.isHidden = !option.showNFTsSample
    }

    func prepareForReuse() {
        icon.image = nil
        title.clearText()
    }
}

extension MenuListItemView {
    private func addBackground(_ theme: MenuListItemViewTheme) {
        customizeAppearance(theme.background)
        layer.cornerRadius = theme.contentViewRadius
    }
    
    private func addIcon(_ theme: MenuListItemViewTheme) {
        addSubview(icon)
        icon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.iconHorizontalPadding)
            $0.centerY.equalToSuperview()
        }
    }

    private func addTitle(_ theme: MenuListItemViewTheme) {
        title.customizeAppearance(theme.title)

        addSubview(title)
        title.snp.makeConstraints {
            $0.leading == icon.snp.trailing + theme.titleHorizontalPadding
            $0.centerY.equalToSuperview()
        }
    }
    
    private func addArrow(_ theme: MenuListItemViewTheme) {
        arrow.customizeAppearance(theme.arrow)
        
        addSubview(arrow)
        arrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.iconHorizontalPadding)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func addNFTsView(_ theme: MenuListItemViewTheme) {
        nftImage1.backgroundColor = .cyan
        nftImage1.clipsToBounds = true
        nftImage1.layer.cornerRadius = 8
        nftImage1.layer.borderWidth = 2
        nftImage1.layer.borderColor = Colors.Layer.grayLighter.uiColor.cgColor
        nftsView.addSubview(nftImage1)
        nftImage1.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(40)
            $0.trailing.equalToSuperview()
        }
        
        nftImage2.backgroundColor = .orange
        nftImage2.clipsToBounds = true
        nftImage2.layer.cornerRadius = 8
        nftImage2.layer.borderWidth = 2
        nftImage2.layer.borderColor = Colors.Layer.grayLighter.uiColor.cgColor
        nftsView.addSubview(nftImage2)
        nftImage2.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(40)
            $0.trailing == nftImage1.snp.leading + 16
        }
        
        nftImage3.backgroundColor = .green
        nftImage3.clipsToBounds = true
        nftImage3.layer.cornerRadius = 8
        nftImage3.layer.borderWidth = 2
        nftImage3.layer.borderColor = Colors.Layer.grayLighter.uiColor.cgColor
        nftsView.addSubview(nftImage3)
        nftImage3.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(40)
            $0.trailing == nftImage2.snp.leading + 16
        }
        
        nftsView.bringSubviewToFront(nftImage2)
        nftsView.bringSubviewToFront(nftImage1)
        
        addSubview(nftsView)
        nftsView.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.trailing == arrow.snp.leading - 12
            $0.centerY.equalToSuperview()
        }
    }
    
    private func addNewLabel(_ theme: MenuListItemViewTheme) {
        newLabel.customizeAppearance(theme.newLabel)
        newLabel.layer.cornerRadius = theme.newLabelRadius
        newLabel.layer.masksToBounds = true

        addSubview(newLabel)
        newLabel.snp.makeConstraints {
            $0.leading == title.snp.trailing + theme.titleHorizontalPadding
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.newLabelSize)
        }
    }
}
