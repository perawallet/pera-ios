// Copyright 2022-2025 Pera Wallet, LDA

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
//  TutorialNumberView.swift

import UIKit
import MacaroonUIKit

final class TutorialNumberView: View {
    private lazy var numberLabel = UILabel()
    
    func customize(_ theme: TutorialNumberViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addNumberLabel(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension TutorialNumberView {
    private func addNumberLabel(_ theme: TutorialNumberViewTheme) {
        numberLabel.customizeAppearance(theme.label)

        addSubview(numberLabel)
        numberLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TutorialNumberView: ViewModelBindable {
    func bindData(_ viewModel: TutorialNumberViewModel?) {
        numberLabel.text = viewModel?.number
    }
}
