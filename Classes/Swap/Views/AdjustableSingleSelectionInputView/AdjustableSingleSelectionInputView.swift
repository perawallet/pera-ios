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

//   AdjustableSingleSelectionInputView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AdjustableSingleSelectionInputView: MacaroonUIKit.BaseView {
    private let selectionInputView: SegmentedControl
    private let textInputView: FloatingTextInputFieldView = .init()
    private let selectionInputScrollView: UIScrollView = .init()

    init(_ theme: AdjustableSingleSelectionInputViewTheme = .init()) {
        self.selectionInputView = SegmentedControl(theme.selectionInput)
        super.init(frame: .zero)

        addUI(theme)
    }

    func bind(_ viewModel: AdjustableSingleSelectionInputViewModel?) {
        let inputs = viewModel?.selectableInputs ?? []
        selectionInputView.add(segments: inputs)
    }
}

extension AdjustableSingleSelectionInputView {
    private func addUI(_ theme: AdjustableSingleSelectionInputViewTheme) {
        addTextInput(theme)
        addSelectionInput(theme)
    }

    private func addTextInput(_ theme: AdjustableSingleSelectionInputViewTheme) {
        textInputView.customize(theme.textInput)

        addSubview(textInputView)
        textInputView.snp.makeConstraints {
            $0.greaterThanHeight(theme.textInputMinHeight)
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addSelectionInput(_ theme: AdjustableSingleSelectionInputViewTheme) {
        addSubview(selectionInputScrollView)
        selectionInputScrollView.showsHorizontalScrollIndicator = false
        selectionInputScrollView.showsVerticalScrollIndicator = false
        selectionInputScrollView.alwaysBounceVertical = false
        selectionInputScrollView.contentInset = theme.selectionInputContentInset
        selectionInputScrollView.snp.makeConstraints {
            $0.top == textInputView.snp.bottom + theme.spacingBetweenTextInputAndSelectionInput
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        selectionInputScrollView.addSubview(selectionInputView)
        selectionInputView.snp.makeConstraints {
            /// <workaround>
            /// Since the scroll views don't have an intrinsic size, the layout adjustments below
            /// will make the height of the scroll view matches with the input view plus content
            /// inset.
            $0.top == 0
            $0.top == textInputView.snp.bottom +
                theme.spacingBetweenTextInputAndSelectionInput +
                theme.selectionInputContentInset.top
            $0.leading == 0
            $0.bottom == 0
            $0.bottom == self - theme.selectionInputContentInset.bottom
            $0.trailing == 0
        }
    }
}
