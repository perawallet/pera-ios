// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MnemonicTypeView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class MnemonicTypeView: TripleShadowView {
    private lazy var rightAccessoryImageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var badgeLabel = UILabel()
    private lazy var detailLabel = UILabel()
    private lazy var infoLabel = UILabel()

    private lazy var badgeView = Label()

    func customize(_ theme: MnemonicTypeViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        drawAppearance(shadow: theme.firstShadow)
        drawAppearance(secondShadow: theme.secondShadow)
        drawAppearance(thirdShadow: theme.thirdShadow)
        addTitleLabel(theme)
        addBadgeLabel(theme)
        addRightAccessoryImageView(theme)
        addDetailLabel(theme)
        addInfo(theme)
    }
}

extension MnemonicTypeView {
    private func addTitleLabel(_ theme: MnemonicTypeViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.verticalInset)
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
        }
    }
    
    private func addBadgeLabel(_ theme: MnemonicTypeViewTheme) {
        
        badgeView.customizeAppearance(theme.badge)
        badgeView.draw(corner: theme.badgeCorner)
        badgeView.contentEdgeInsets = theme.badgeContentEdgeInsets

        addSubview(badgeView)
        badgeView.snp.makeConstraints {
            $0.height >= titleLabel
            $0.centerY == titleLabel
            $0.leading == titleLabel.snp.trailing + theme.spacingBetweenbadgeAndName
            $0.trailing <= 0
        }
    }

    private func addRightAccessoryImageView(_ theme: MnemonicTypeViewTheme) {
        addSubview(rightAccessoryImageView)
        
        rightAccessoryImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.fitToSize(theme.iconSize)
            $0.centerY.equalToSuperview()
        }
    }

    
    private func addDetailLabel(_ theme: MnemonicTypeViewTheme) {
        detailLabel.customizeAppearance(theme.detail)

        addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.equalTo(rightAccessoryImageView.snp.leading).offset(theme.detailTrailingInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.minimumInset)
        }
    }

    
    private func addInfo(_ theme: MnemonicTypeViewTheme) {
        infoLabel.customizeAppearance(theme.info)

        addSubview(infoLabel)
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(theme.verticalInset)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.bottom.equalToSuperview().inset(theme.verticalInset)
        }
    }
}

extension MnemonicTypeView: ViewModelBindable {
    func bindData(_ viewModel: MnemonicTypeViewModel?) {
        rightAccessoryImageView.image = viewModel?.image
        viewModel?.title?.load(in: titleLabel)
        viewModel?.detail?.load(in: detailLabel)
        viewModel?.info?.load(in: infoLabel)
        viewModel?.isRecommended?.load(in: badgeView)
    }
}
