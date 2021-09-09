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
//  OptionsContextView.swift

import UIKit
import Macaroon

final class OptionsContextView: View {
    private(set) lazy var iconImageView = UIImageView()
    private(set) lazy var optionLabel = UILabel()

    func customize(_ theme: OptionsContextViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addIconImageView(theme)
        addOptionLabel(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension OptionsContextView {
    private func addIconImageView(_ theme: OptionsContextViewTheme) {
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
        }
    }
    
    private func addOptionLabel(_ theme: OptionsContextViewTheme) {
        optionLabel.customizeAppearance(theme.label)

        addSubview(optionLabel)
        optionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.labelLeftInset)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
}

extension OptionsContextView {
    func bind(_ viewModel: OptionsViewModel) {
        iconImageView.image = viewModel.image
        optionLabel.text = viewModel.title
        optionLabel.textColor = viewModel.titleColor
    }

    func bind(_ viewModel: AccountRecoverOptionsViewModel) {
        iconImageView.image = viewModel.image
        optionLabel.text = viewModel.title
    }
}
