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

//
//   RecoverInputViewModel.swift

import UIKit

final class RecoverInputViewModel {
    private(set) var number: String?
    private(set) var numberColor: UIColor?
    private(set) var passphraseColor: UIColor?
    private(set) var seperatorColor: UIColor?

    init(state: RecoverInputView.State, index: Int) {
        setNumber(from: index)
        setNumberColor(from: state)
        setPassphraseColor(from: state)
        setSeparatorColor(from: state)
    }

    private func setNumber(from index: Int) {
        number = "\(index + 1)"
    }

    private func setNumberColor(from state: RecoverInputView.State) {
        switch state {
        case .wrong,
             .filledWrongly:
            numberColor = AppColors.Shared.Helpers.negative.uiColor
        case .active,
             .empty,
             .filled:
            numberColor = AppColors.Components.Text.main.uiColor
        }
    }

    private func setPassphraseColor(from state: RecoverInputView.State) {
        switch state {
        case .wrong,
             .filledWrongly:
            passphraseColor = AppColors.Shared.Helpers.negative.uiColor
        case .active,
             .empty,
             .filled:
            passphraseColor = AppColors.Components.Text.main.uiColor
        }
    }

    private func setSeparatorColor(from state: RecoverInputView.State) {
        switch state {
        case .wrong,
             .filledWrongly:
            seperatorColor = AppColors.Shared.Helpers.negative.uiColor
        case .active:
            seperatorColor = AppColors.Components.Text.main.uiColor
        case .empty,
             .filled:
            seperatorColor = AppColors.Shared.Layer.gray.uiColor
        }
    }
}
