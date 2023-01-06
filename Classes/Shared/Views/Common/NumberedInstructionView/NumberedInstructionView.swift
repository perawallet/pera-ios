// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   NumberedInstructionView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class NumberedInstructionView: View {
    private lazy var numberBackgroundView = ImageView()
    private lazy var numberView = Label()
    private lazy var titleView = Label()

    func customize(_ theme: NumberedInstructionViewTheme) {
        addTitle(theme)
        addNumberBackground(theme)
        addNumber(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension NumberedInstructionView {
    private func addNumberBackground(_ theme: NumberedInstructionViewTheme) {
        numberBackgroundView.customizeAppearance(theme.background)

        addSubview(numberBackgroundView)
        numberBackgroundView.snp.makeConstraints {
            $0.trailing.equalTo(titleView.snp.leading).offset(-theme.horizontalPadding)
            $0.leading.equalToSuperview()
            $0.centerY.equalTo(titleView).offset(theme.numberBackgroundCenterYOffset)
            $0.fitToSize(theme.numberImageSize)
        }
    }

    private func addNumber(_ theme: NumberedInstructionViewTheme) {
        numberView.customizeAppearance(theme.number)

        addSubview(numberView)
        numberView.snp.makeConstraints {
            $0.top.equalTo(numberBackgroundView.snp.top).offset(theme.numberTopInset)
            $0.centerX.equalTo(numberBackgroundView)
        }
    }

    private func addTitle(_ theme: NumberedInstructionViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.greaterThanHeight(theme.numberImageSize.h)
        }
    }
}

extension NumberedInstructionView {
    func bind(_ viewModel: NumberedInstructionViewModel?) {
        viewModel?.title?.load(in: titleView)
        viewModel?.number?.load(in: numberView)
    }
}
