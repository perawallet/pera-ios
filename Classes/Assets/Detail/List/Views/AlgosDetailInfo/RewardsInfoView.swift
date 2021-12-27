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
//   RewardsInfoView.swift

import UIKit
import MacaroonUIKit

final class RewardsInfoView: View {
    weak var delegate: RewardsInfoViewDelegate?

    private lazy var rewardsRateTitleLabel = UILabel()
    private lazy var rewardsRateValueLabel = UILabel()
    private lazy var verticalSeparator = UIView()
    private lazy var rewardsLabel = UILabel()
    private lazy var rewardsValueLabel = UILabel()
    private lazy var infoButton = UIButton()

    func setListeners() {
        infoButton.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
    }

    func customize(_ theme: RewardsInfoViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addRewardsRateTitleLabel(theme)
        addRewardsRateValueLabel(theme)
        addInfoButton(theme)
        addRewardsLabel(theme)
        addRewardsValueLabel(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension RewardsInfoView {
    @objc
    private func didTapInfoButton() {
        delegate?.rewardsInfoViewDidTapInfoButton(self)
    }
}

extension RewardsInfoView {
    private func addRewardsRateTitleLabel(_ theme: RewardsInfoViewTheme) {
        rewardsRateTitleLabel.customizeAppearance(theme.rewardsRateTitleLabel)

        addSubview(rewardsRateTitleLabel)
        rewardsRateTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.rewardsRateTitleLabelTopPadding)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
        }

        addVerticalSeparator(theme)
    }

    private func addRewardsRateValueLabel(_ theme: RewardsInfoViewTheme) {
        rewardsRateValueLabel.customizeAppearance(theme.rewardsRateValueLabel)

        addSubview(rewardsRateValueLabel)
        rewardsRateValueLabel.snp.makeConstraints {
            $0.top.equalTo(rewardsRateTitleLabel.snp.bottom).offset(theme.rewardsRateValueLabelTopPadding)
            $0.leading.equalTo(rewardsRateTitleLabel)
            $0.bottom.equalToSuperview().inset(theme.bottomPadding)
        }
    }

    private func addVerticalSeparator(_ theme: RewardsInfoViewTheme) {
        verticalSeparator.backgroundColor = theme.separator.color.uiColor

        addSubview(verticalSeparator)
        verticalSeparator.snp.makeConstraints {
            $0.fitToWidth(theme.separator.size)
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(rewardsRateTitleLabel.snp.trailing).offset(theme.verticalSeparatorLeadingPadding)
        }
    }

    private func addInfoButton(_ theme: RewardsInfoViewTheme) {
        infoButton.customizeAppearance(theme.infoButton)

        addSubview(infoButton)
        infoButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addRewardsLabel(_ theme: RewardsInfoViewTheme) {
        rewardsLabel.customizeAppearance(theme.rewardsLabel)

        addSubview(rewardsLabel)
        rewardsLabel.snp.makeConstraints {
            $0.centerY.equalTo(rewardsRateTitleLabel)
            $0.leading.equalTo(rewardsRateTitleLabel.snp.trailing).offset(theme.rewardsLabelLeadingPadding)
            $0.trailing.lessThanOrEqualTo(infoButton.snp.leading).offset(theme.minimumHorizontalInset)
        }
    }

    private func addRewardsValueLabel(_ theme: RewardsInfoViewTheme) {
        rewardsValueLabel.customizeAppearance(theme.rewardsValueLabel)

        addSubview(rewardsValueLabel)
        rewardsValueLabel.snp.makeConstraints {
            $0.top.equalTo(rewardsLabel.snp.bottom).offset(theme.rewardsRateValueLabelTopPadding)
            $0.leading.equalTo(rewardsLabel)
            $0.trailing.lessThanOrEqualTo(infoButton.snp.leading).offset(theme.minimumHorizontalInset)
            $0.bottom.equalToSuperview().inset(theme.bottomPadding)
        }
    }
}

extension RewardsInfoView: ViewModelBindable {
    func bindData(_ viewModel: RewardDetailViewModel?) {
        rewardsRateValueLabel.text = viewModel?.rate
        rewardsValueLabel.text = viewModel?.amount
    }
}

protocol RewardsInfoViewDelegate: AnyObject {
    func rewardsInfoViewDidTapInfoButton(_ rewardsInfoView: RewardsInfoView)
}
