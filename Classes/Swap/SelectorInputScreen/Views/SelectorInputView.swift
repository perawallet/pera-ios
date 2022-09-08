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

//   SelectorInputView.swift

import UIKit
import MacaroonUIKit
import MacaroonForm

final class SelectorInputView:
    View,
    ViewModelBindable {
    private(set) lazy var textInputView = FloatingTextInputFieldView()
    private lazy var selectorOptionsView = SegmentedControl()

    func customize(_ theme: SelectorInputViewTheme) {
        addTextInput(theme)
        addSelectorOptions(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: SelectorInputViewModel?) {
        selectorOptionsView.removeAllSegments()

        if let options = viewModel?.selectorOptions {
            selectorOptionsView.add(segments: options)
        }

        if let selectedIndex = viewModel?.defaultSelectedIndex {
            selectorOptionsView.selectedSegmentIndex = selectedIndex
        }
    }
}

extension SelectorInputView {
    private func addTextInput(_ theme: SelectorInputViewTheme) {
        textInputView.customize(theme.textInput)

        addSubview(textInputView)
        textInputView.snp.makeConstraints {
            $0.greaterThanHeight(theme.textInputHeight)
            $0.top == theme.textInputTopPadding
            $0.leading.trailing == theme.horizontalPadding
        }
    }

    private func addSelectorOptions(_ theme: SelectorInputViewTheme) {
        selectorOptionsView.spacingBetweenSegments = theme.selectorOptionsSpacing

        addSubview(selectorOptionsView)
        selectorOptionsView.snp.makeConstraints {
            $0.top == textInputView.snp.bottom + theme.selectorOptionsTopPadding
            $0.leading == theme.horizontalPadding
            $0.trailing >= theme.selectorOptionsTrailingPadding
            $0.bottom == theme.selectorOptionsBottomPadding
        }
    }
}

extension SelectorInputView {
    func resetSelectedOption() {
        selectorOptionsView.selectedSegmentIndex = -1
    }

    func setBottomPadding() {
        selectorOptionsView.snp.updateConstraints {
            $0.bottom == 40
        }
    }

    func setBottomPaddingForKeyboard(_ bottomPadding: LayoutMetric) {
        selectorOptionsView.snp.updateConstraints {
            $0.bottom == bottomPadding
        }
    }
}
