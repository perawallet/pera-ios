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
//  RewardDetailView.swift

import UIKit
import MacaroonUIKit

final class RewardDetailView: View {
    weak var delegate: RewardDetailViewDelegate?

    private lazy var rewardsRateTitleLabel = UILabel()
    private lazy var rewardsRateValueLabel = UILabel()
    private lazy var rewardsLabel = UILabel()
    private lazy var algoImageView = UIImageView()
    private lazy var rewardsValueLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var FAQLabel = UILabel()

    func setListeners() {
        FAQLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTriggerFAQLabel))
        )
    }
    
    func customize(_ theme: RewardDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addRewardsRateTitleLabel(theme)
        addRewardsRateValueLabel(theme)
        addRewardsLabel(theme)
        addAlgoImageView(theme)
        addAssetIDInfoButton(theme)
        addDescriptionLabel(theme)
        addFAQLabel(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension RewardDetailView {
    @objc
    private func didTriggerFAQLabel() {
        delegate?.rewardDetailViewDidTapFAQLabel(self)
    }
}

extension RewardDetailView {
    private func addRewardsRateTitleLabel(_ theme: RewardDetailViewTheme) {
        rewardsRateTitleLabel.customizeAppearance(theme.rewardsRateTitleLabel)

        addSubview(rewardsRateTitleLabel)
        rewardsRateTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.rewardsRateTitleLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addRewardsRateValueLabel(_ theme: RewardDetailViewTheme) {
        rewardsRateValueLabel.customizeAppearance(theme.rewardsValueLabel)

        addSubview(rewardsRateValueLabel)
        rewardsRateValueLabel.snp.makeConstraints {
            $0.top.equalTo(rewardsRateTitleLabel.snp.bottom).offset(theme.rewardsRateValueLabelTopPadding)
            $0.leading.equalTo(rewardsRateTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addRewardsLabel(_ theme: RewardDetailViewTheme) {
        rewardsLabel.customizeAppearance(theme.rewardsLabel)

        addSubview(rewardsLabel)
        rewardsLabel.snp.makeConstraints {
            $0.top.equalTo(rewardsRateValueLabel.snp.bottom).offset(theme.rewardsRateTitleLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addAlgoImageView(_ theme: RewardDetailViewTheme) {
        algoImageView.customizeAppearance(theme.algoImageView)

        addSubview(algoImageView)
        algoImageView.snp.makeConstraints {
            $0.top.equalTo(rewardsLabel.snp.bottom).offset(theme.algoImageViewTopPadding)
            $0.leading.equalTo(rewardsLabel)
            $0.fitToSize(theme.algoImageViewSize)
        }

        rewardsLabel.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addAssetIDInfoButton(_ theme: RewardDetailViewTheme) {
        rewardsValueLabel.customizeAppearance(theme.rewardsValueLabel)
        addSubview(rewardsValueLabel)
        rewardsValueLabel.snp.makeConstraints {
            $0.leading.equalTo(algoImageView.snp.trailing).offset(theme.rewardsLabelLeadingPadding)
            $0.centerY.equalTo(algoImageView)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addDescriptionLabel(_ theme: RewardDetailViewTheme) {
        descriptionLabel.customizeAppearance(theme.descriptionLabel)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(rewardsValueLabel.snp.bottom).offset(theme.descriptionLabelTopPadding)
        }
    }

    private func addFAQLabel(_ theme: RewardDetailViewTheme) {
        FAQLabel.customizeAppearance(theme.FAQLabel)

        let totalString = "total-rewards-faq-title".localized
        let FAQString = "total-rewards-faq".localized
        let attributedText = NSMutableAttributedString(string: totalString)
        attributedText.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: theme.FAQLabelLinkTextColor.uiColor,
            range: (totalString as NSString).range(of: FAQString)
        )
        FAQLabel.attributedText = attributedText

        addSubview(FAQLabel)
        FAQLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.FAQLabelTopPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }
}

extension RewardDetailView: ViewModelBindable {
    func bindData(_ viewModel: RewardDetailViewModel?) {
        rewardsRateValueLabel.text = viewModel?.rate
        rewardsValueLabel.text = viewModel?.amount
    }
}

protocol RewardDetailViewDelegate: AnyObject {
    func rewardDetailViewDidTapFAQLabel(_ rewardDetailView: RewardDetailView)
}
