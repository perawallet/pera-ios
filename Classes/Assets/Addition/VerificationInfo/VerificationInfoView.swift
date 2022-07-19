// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   VerificationInfoView.swift

import UIKit
import MacaroonUIKit

final class VerificationInfoView: View {
    private lazy var titleLabel = Label()
    private lazy var firstDescriptionLabel = Label()
    private lazy var secondDescriptionLabel = Label()
    private lazy var thirdDescriptionLabel = Label()

    func customize(_ theme: VerificationInfoViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleLabel(theme)
        addDescription(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension VerificationInfoView {
    private func addTitleLabel(_ theme: VerificationInfoViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addDescription(_ theme: VerificationInfoViewTheme) {
        addFirstDescriptionLabel(theme)
        addSecondDescriptionLabel(theme)
        addThirdDescriptionLabel(theme)
    }

    private func addFirstDescriptionLabel(_ theme: VerificationInfoViewTheme) {
        firstDescriptionLabel.customizeAppearance(theme.description)

        addSubview(firstDescriptionLabel)
        firstDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.descriptionTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addSecondDescriptionLabel(_ theme: VerificationInfoViewTheme) {
        secondDescriptionLabel.customizeAppearance(theme.description)

        addSubview(secondDescriptionLabel)
        secondDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(firstDescriptionLabel.snp.bottom).offset(theme.descriptionTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addThirdDescriptionLabel(_ theme: VerificationInfoViewTheme) {
        thirdDescriptionLabel.customizeAppearance(theme.description)

        addSubview(thirdDescriptionLabel)
        thirdDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(secondDescriptionLabel.snp.bottom).offset(theme.descriptionTopPadding)
            $0.leading.trailing.bottom.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
}
