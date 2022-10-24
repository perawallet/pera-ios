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

//   AdjustSwapAmountScreen.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit
import UIKit

final class AdjustSwapAmountScreen:
    BaseViewController,
    BottomSheetPresentable {
    let modalHeight: MacaroonUIKit.ModalHeight = .compressed

    private lazy var balancePercentageInputView =
        AdjustableSingleSelectionInputView(theme.balancePercentageInput)

    private let theme: AdjustSwapAmountScreenTheme = .init()

    override func configureNavigationBarAppearance() {
        navigationItem.title = "swap-amount-balancePercentage-title".localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
    }
}

extension AdjustSwapAmountScreen {
    private func addUI() {
        addBalancePercentageInput()
    }

    private func addBalancePercentageInput() {
        view.addSubview(balancePercentageInputView)
        balancePercentageInputView.snp.makeConstraints {
            $0.top == 50
            $0.leading == 24
            $0.bottom <= 50
            $0.trailing == 24
        }

        balancePercentageInputView.bind(BalancePercentageInputViewModel())
    }
}
