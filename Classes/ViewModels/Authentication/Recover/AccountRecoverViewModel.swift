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
        delegate?.accountRecoverViewModel(self, didBeginEditing: recoverInputView)
    }

    func recoverInputViewDidChange(_ recoverInputView: RecoverInputView) {
        delegate?.accountRecoverViewModel(self, didChangeInputIn: recoverInputView)
    }

    func recoverInputViewDidEndEditing(_ recoverInputView: RecoverInputView) {
        recoverInputView.bind(RecoverInputViewModel(state: .filled, index: recoverInputView.tag))
        delegate?.accountRecoverViewModel(self, didEndEditing: recoverInputView)
    }

    func recoverInputViewShouldReturn(_ recoverInputView: RecoverInputView) -> Bool {
        if isLastInputView(recoverInputView) {
            delegate?.accountRecoverViewModelDidRecover(self)
            return true
        }

        if let nextInputView = nextInputView(of: recoverInputView) {
            nextInputView.beginEditing()
        }

        return true
    }

    func recoverInputView(
        _ recoverInputView: RecoverInputView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        return string != " "
    }
}

extension AccountRecoverViewModel {
    private func shouldBeginEditingInputView(_ recoverInputView: RecoverInputView) -> Bool {
        return isPreviousInputViewFilled(recoverInputView)
    }

    private func isPreviousInputViewFilled(_ recoverInputView: RecoverInputView) -> Bool {
        if isFirstInputView(recoverInputView) {
            return true
        }

        if let previousInputView = previousInputView(of: recoverInputView) {
            return previousInputView.isFilled
        }

        return false
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
}

protocol AccountRecoverViewModelDelegate: class {
    func accountRecoverViewModel(_ viewModel: AccountRecoverViewModel, didBeginEditing view: RecoverInputView)
    func accountRecoverViewModel(_ viewModel: AccountRecoverViewModel, didChangeInputIn view: RecoverInputView)
    func accountRecoverViewModel(_ viewModel: AccountRecoverViewModel, didEndEditing view: RecoverInputView)
    func accountRecoverViewModelDidRecover(_ viewModel: AccountRecoverViewModel)
}
