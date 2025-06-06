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
//  ChoosePasswordViewModel.swift

import UIKit
import MacaroonUIKit

/// <todo>
/// Refactor
final class ChoosePasswordViewModel: PairedViewModel {
    private var password: String = .empty
    
    private var isPasswordValid: Bool {
        return password.count == 6
    }

    private let mode: ChoosePasswordViewController.Mode
    
    init(_ model: ChoosePasswordViewController.Mode) {
        self.mode = model
    }
}

extension ChoosePasswordViewModel {
    func configure(_ choosePasswordView: ChoosePasswordView) {
        switch mode {
        case .setup:
            choosePasswordView.titleLabel.text = String(localized: "password-set-subtitle")
        case .verify:
            choosePasswordView.titleLabel.text = String(localized: "password-verify-subtitle")
        case .login:
            choosePasswordView.titleLabel.text = String(localized: "title-enter-pin")
        case .deletePassword:
            choosePasswordView.titleLabel.text = String(localized: "title-enter-pin")
        case .resetPassword(let flow):
            switch flow {
            case .initial:
                choosePasswordView.titleLabel.text = String(localized: "password-set-subtitle")
            case .fromVerifyOld:
                choosePasswordView.titleLabel.text = String(localized: "password-change-new-subtitle")
            }
        case .resetVerify(_, let flow):
            switch flow {
            case .initial:
                choosePasswordView.titleLabel.text = String(localized: "password-verify-subtitle")
            case .fromVerifyOld:
                choosePasswordView.titleLabel.text = String(localized: "password-verify-new-subtitle")
            }
        case .confirm:
            choosePasswordView.titleLabel.text = String(localized: "title-enter-pin")
        case .verifyOld:
            choosePasswordView.titleLabel.text = String(localized: "password-change-old-subtitle")
        }
    }

    func configureSelection(
        in choosePasswordView: ChoosePasswordView,
        for value: NumpadButton.NumpadKey,
        then handler: (String) -> Void
    ) {
        switch value {
        case let .number(number):
            if isPasswordValid {
                handler(password)
                return
            }

            password.append(number)
        case .delete:
            if !password.isEmpty {
                password.removeLast()
            }
        case .spacing, .decimalSeparator:
            break
        }

        if isPasswordValid {
            update(in: choosePasswordView, for: value)
            handler(password)
            return
        }

        choosePasswordView.toggleDeleteButtonVisibility(for: password.isEmpty)
        update(in: choosePasswordView, for: value)
    }

    private func update(in choosePasswordView: ChoosePasswordView, for value: NumpadButton.NumpadKey) {
        switch value {
        case .number:
            let passwordInputCircleView =
            choosePasswordView.passwordInputView.passwordInputCircleViews[password.count - 1]

            if passwordInputCircleView.state == .error {
                choosePasswordView.changeStateTo(.empty)
            }

            passwordInputCircleView.state = .filled
        case .delete:
            if isPasswordValid {
                let passwordInputCircleView = choosePasswordView.passwordInputView.passwordInputCircleViews[password.count - 1]
                passwordInputCircleView.state = .empty
                return
            }

            let passwordInputCircleView =
            choosePasswordView.passwordInputView.passwordInputCircleViews[password.count]

            if passwordInputCircleView.state == .error {
                return
            }

            passwordInputCircleView.state = .empty
            return
        case .spacing, .decimalSeparator:
            break
        }
    }

    func reset() {
        password = .empty
    }
}
