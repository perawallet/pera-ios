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
//   AccountRecoverViewModel.swift

import Foundation

class AccountRecoverViewModel {

    weak var delegate: AccountRecoverViewModelDelegate?

    private let totalMnemonicCount = 25
    private let firstColumnCount = 13
    private let secondColumnCount = 12

    private var inputViews = [RecoverInputView]()

    private var inputViewId: Int {
        return inputViews.count
    }

    var currentInputView: RecoverInputView?

    var isRecoverEnabled: Bool {
        return getMnemonics() != nil
    }
}

extension AccountRecoverViewModel {
    func getMnemonics() -> String? {
        let inputs = inputViews.compactMap { $0.input }.filter { !$0.isEmpty }
        if inputs.count == totalMnemonicCount {
            return inputs.joined(separator: " ")
        }
        return nil
    }

    func fillMnemonics(_ mnemonics: [String]) {
        for (index, inputView) in inputViews.enumerated() {
            inputView.setText(mnemonics[index])
        }
    }

    func updateCurrentInputView(with mnemonic: String) {
        guard let currentInputView = currentInputView else {
            return
        }
        
        currentInputView.setText(mnemonic)
        finishUpdates(for: currentInputView)
    }
}

extension AccountRecoverViewModel {
    func addInputViews(to view: AccountRecoverView) {
        fillTheFirstColumn(in: view)
        fillTheSecondColumn(in: view)
    }

    private func fillTheFirstColumn(in view: AccountRecoverView) {
        for index in 0...firstColumnCount - 1 {
            let inputView = composeInputView()
            if index == 0 {
                currentInputView = inputView
            }
            view.addInputViewToFirstColumn(inputView)
        }
    }

    private func fillTheSecondColumn(in view: AccountRecoverView) {
        for _ in 0...secondColumnCount - 1 {
            let inputView = composeInputView()
            view.addInputViewToSecondColumn(inputView)
        }
    }

    private func composeInputView() -> RecoverInputView {
        let inputView = RecoverInputView()
        inputView.delegate = self
        inputView.bind(RecoverInputViewModel(state: .empty, index: inputViewId))
        inputView.tag = inputViewId
        inputViews.append(inputView)

        if inputViews.count == totalMnemonicCount {
            inputView.returnKey = .go
        } else {
            inputView.returnKey = .next
        }

        return inputView
    }
}

extension AccountRecoverViewModel: RecoverInputViewDelegate {
    func recoverInputViewShouldBeginEditing(_ recoverInputView: RecoverInputView) -> Bool {
        return shouldBeginEditingInputView(recoverInputView)
    }

    func recoverInputViewDidBeginEditing(_ recoverInputView: RecoverInputView) {
        currentInputView = recoverInputView
        recoverInputView.bind(RecoverInputViewModel(state: .active, index: recoverInputView.tag))
    }

    func recoverInputViewDidChange(_ recoverInputView: RecoverInputView) {
        delegate?.accountRecoverViewModel(self, didChangeInputIn: recoverInputView)
    }

    func recoverInputViewDidEndEditing(_ recoverInputView: RecoverInputView) {
        recoverInputView.bind(RecoverInputViewModel(state: .filled, index: recoverInputView.tag))
    }

    func recoverInputViewShouldReturn(_ recoverInputView: RecoverInputView) -> Bool {
        finishUpdates(for: recoverInputView)
        return true
    }

    private func finishUpdates(for recoverInputView: RecoverInputView) {
        if !hasValidSuggestion(for: recoverInputView) {
            return
        }

        recoverInputView.removeInputAccessoryView()
        
        if isLastInputView(recoverInputView) {
            delegate?.accountRecoverViewModelDidRecover(self)
        } else if let nextInputView = nextInputView(of: recoverInputView) {
            nextInputView.beginEditing()
        }
    }

    func recoverInputView(
        _ recoverInputView: RecoverInputView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        return shouldUpdateTextField(with: string)
    }
}

extension AccountRecoverViewModel {
    private func shouldBeginEditingInputView(_ recoverInputView: RecoverInputView) -> Bool {
        return isPreviousInputViewFilledCorrectly(recoverInputView)
    }

    private func isPreviousInputViewFilledCorrectly(_ recoverInputView: RecoverInputView) -> Bool {
        if isFirstInputView(recoverInputView) {
            return true
        }

        if let previousInputView = previousInputView(of: recoverInputView) {
            return previousInputView.isFilled && hasValidSuggestion(for: previousInputView)
        }

        return false
    }

    private func hasValidSuggestion(for view: RecoverInputView) -> Bool {
        guard let delegate = delegate else {
            return true
        }

        return delegate.accountRecoverViewModel(self, hasValidSuggestionFor: view)
    }

    private func previousInputView(of recoverInputView: RecoverInputView) -> RecoverInputView? {
        if isFirstInputView(recoverInputView) {
            return nil
        }

        let previousInputId = recoverInputView.tag - 1
        return inputViews[safe: previousInputId]
    }

    private func nextInputView(of recoverInputView: RecoverInputView) -> RecoverInputView? {
        if isLastInputView(recoverInputView) {
            return nil
        }

        let nextInputId = recoverInputView.tag + 1
        return inputViews[safe: nextInputId]
    }

    private func isFirstInputView(_ recoverInputView: RecoverInputView) -> Bool {
        return inputViews.first == recoverInputView
    }

    private func isLastInputView(_ recoverInputView: RecoverInputView) -> Bool {
        return inputViews.last == recoverInputView
    }

    private func shouldUpdateTextField(with string: String) -> Bool {
        let mnemonics = string.split(separator: " ").map { String($0) }

        if containsOneMnemonic(mnemonics) {
            return string != " "
        } else if isValidMnemonicCount(mnemonics) {
            // If copied text is a valid mnemonc, fill automatically.
            fillMnemonics(mnemonics)
            return false
        } else {
            // Invalid copy/paste action for mnemonics.
            delegate?.accountRecoverViewModelDidFailedPastingFromClipboard(self)
            return false
        }
    }

    private func containsOneMnemonic(_ mnemonics: [String]) -> Bool {
        return mnemonics.count <= 1
    }

    private func isValidMnemonicCount(_ mnemonics: [String]) -> Bool {
        return mnemonics.count == totalMnemonicCount
    }
}

extension AccountRecoverViewModel {
    func updateMnemonicsFromPasteboard(_ text: String) {
        let mnemonics = text.split(separator: " ").map { String($0) }

        if containsOneMnemonic(mnemonics) {
            if let firstText = mnemonics[safe: 0],
               !firstText.trimmed.isEmpty {
                updateCurrentInputView(with: text)
            }
        } else if isValidMnemonicCount(mnemonics) {
            // If copied text is a valid mnemonc, fill automatically.
            fillMnemonics(mnemonics)
        } else {
            // Invalid copy/paste action for mnemonics.
            delegate?.accountRecoverViewModelDidFailedPastingFromClipboard(self)
        }
    }
}

protocol AccountRecoverViewModelDelegate: class {
    func accountRecoverViewModel(_ viewModel: AccountRecoverViewModel, didChangeInputIn view: RecoverInputView)
    func accountRecoverViewModelDidRecover(_ viewModel: AccountRecoverViewModel)
    func accountRecoverViewModel(_ viewModel: AccountRecoverViewModel, hasValidSuggestionFor view: RecoverInputView) -> Bool
    func accountRecoverViewModelDidFailedPastingFromClipboard(_ viewModel: AccountRecoverViewModel)
}
