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
//   AlgosDetailInfoView.swift

import MacaroonUIKit
import UIKit

final class AlgosDetailInfoView: View {
    weak var delegate: AlgosDetailInfoViewDelegate?

    private lazy var yourBalanceTitleLabel = UILabel()
    private lazy var valueTitleLabel = UILabel()
    private lazy var algoImageView = UIImageView()
    private lazy var algosValueLabel = UILabel()
    private lazy var secondaryValueLabel = UILabel()
    private lazy var rewardsInfoView = RewardsInfoView()

    func customize(_ theme: AlgosDetailInfoViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addYourBalanceTitleLabel(theme)
        addValueTitleLabel(theme)
        addAlgoImageView(theme)
        addAlgosValueLabel(theme)
        addSecondaryValueLabel(theme)
        addRewardsInfoView(theme)
    }

    func setListeners() {
        rewardsInfoView.setListeners()
        rewardsInfoView.delegate = self
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension AlgosDetailInfoView {
    private func addYourBalanceTitleLabel(_ theme: AlgosDetailInfoViewTheme) {
        yourBalanceTitleLabel.customizeAppearance(theme.yourBalanceTitleLabel)

        addSubview(yourBalanceTitleLabel)
        yourBalanceTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addValueTitleLabel(_ theme: AlgosDetailInfoViewTheme) {
        valueTitleLabel.customizeAppearance(theme.valueTitleLabel)

        addSubview(valueTitleLabel)
        valueTitleLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(yourBalanceTitleLabel.snp.trailing).inset(theme.minimumHorizontalInset)
        }
    }

    private func addAlgoImageView(_ theme: AlgosDetailInfoViewTheme) {
        algoImageView.customizeAppearance(theme.algoImageView)

        addSubview(algoImageView)
        algoImageView.snp.makeConstraints {
            $0.top.equalTo(yourBalanceTitleLabel.snp.bottom).offset(theme.algoImageViewTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.fitToSize(theme.algoImageViewSize)
        }
    }

    private func addAlgosValueLabel(_ theme: AlgosDetailInfoViewTheme) {
        algosValueLabel.customizeAppearance(theme.algosValueLabel)

        addSubview(algosValueLabel)
        algosValueLabel.snp.makeConstraints {
            $0.leading.equalTo(algoImageView.snp.trailing).offset(theme.algosValueLabelLeadingPadding)
            $0.centerY.equalTo(algoImageView)
        }
    }

    private func addSecondaryValueLabel(_ theme: AlgosDetailInfoViewTheme) {
        secondaryValueLabel.customizeAppearance(theme.secondaryValueLabel)

        addSubview(secondaryValueLabel)
        secondaryValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(algoImageView)
            $0.trailing.equalTo(valueTitleLabel)
            $0.leading.greaterThanOrEqualTo(algosValueLabel.snp.trailing).inset(theme.minimumHorizontalInset)
        }
    }

    private func addRewardsInfoView(_ theme: AlgosDetailInfoViewTheme) {
        rewardsInfoView.customize(theme.rewardsInfoViewTheme)

        addSubview(rewardsInfoView)
        rewardsInfoView.snp.makeConstraints {
            $0.top.equalTo(algosValueLabel.snp.bottom).offset(theme.rewardsInfoViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview()
        }
    }
}

extension AlgosDetailInfoView: RewardsInfoViewDelegate {
    func rewardsInfoViewDidTapInfoButton(_ rewardsInfoView: RewardsInfoView) {
        delegate?.algosDetailInfoViewDidTapInfoButton(self)
    }
}

protocol AlgosDetailInfoViewDelegate: AnyObject {
    func algosDetailInfoViewDidTapInfoButton(_ algosDetailInfoView: AlgosDetailInfoView)
}

extension AlgosDetailInfoView: ViewModelBindable {
    func bindData(_ viewModel: AlgosDetailInfoViewModel?) {
        algosValueLabel.text = viewModel?.totalAmount
        secondaryValueLabel.text = viewModel?.secondaryValue
        rewardsInfoView.bindData(viewModel?.rewardsInfoViewModel)
    }
}
