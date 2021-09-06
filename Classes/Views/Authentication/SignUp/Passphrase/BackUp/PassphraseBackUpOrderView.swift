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
//  PassphraseBackUpOrderView.swift

import UIKit
import Macaroon

final class PassphraseBackUpOrderView: View {
    private lazy var numberLabel = UILabel()
    private lazy var phraseLabel = UILabel()

    func customize(_ theme: PassphraseBackUpOrderViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addNumberLabel(theme)
        addPhraseLabel(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension PassphraseBackUpOrderView {
    private func addNumberLabel(_ theme: PassphraseBackUpOrderViewTheme) {
        numberLabel.customizeAppearance(theme.numberLabel)

        addSubview(numberLabel)
        numberLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    private func addPhraseLabel(_ theme: PassphraseBackUpOrderViewTheme) {
        phraseLabel.customizeAppearance(theme.phraseLabel)
        
        addSubview(phraseLabel)
        phraseLabel.snp.makeConstraints {
            $0.centerY.equalTo(numberLabel)
            $0.leading.equalTo(numberLabel.snp.trailing).offset(theme.leadingInset)
            $0.trailing.lessThanOrEqualToSuperview()
        }

        phraseLabel.setContentHuggingPriority(.required, for: .horizontal)
        phraseLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}

extension PassphraseBackUpOrderView: ViewModelBindable {
    func bindData(_ viewModel: PassphraseBackUpOrderViewModel?) {
        numberLabel.text = viewModel?.number
        phraseLabel.text = viewModel?.phrase
    }
}
