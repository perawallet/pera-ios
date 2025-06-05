// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MnemonicTypeSelectionView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class MnemonicTypeSelectionView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performAlgo25Action: GestureInteraction(),
        .performBip39Action: GestureInteraction()
    ]

    private lazy var stackView = UIStackView()
    private lazy var bip39View = MnemonicTypeView()
    private lazy var algo25View = MnemonicTypeView()
    
    func customize(_ theme: MnemonicTypeSelectionViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addStackView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: MnemonicTypeSelectionViewModel?) {
        bip39View.bindData(viewModel?.bip39ViewModel)
        algo25View.bindData(viewModel?.algo25ViewModel)
    }
}

extension MnemonicTypeSelectionView {

    private func addStackView(_ theme: MnemonicTypeSelectionViewTheme) {
        stackView.axis = .vertical
        stackView.spacing = theme.verticalInset
        stackView.distribution = .fill
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.verticalInset)
            $0.bottom.equalToSuperview().inset(theme.verticalInset*2)
        }

        bip39View.customize(theme.bip39ViewTheme)
        stackView.addArrangedSubview(bip39View)
        algo25View.customize(theme.algo25ViewTheme)
        stackView.addArrangedSubview(algo25View)
        
        startPublishing(
            event: .performBip39Action,
            for: bip39View
        )
        
        startPublishing(
            event: .performAlgo25Action,
            for: algo25View
        )
    }
}

extension MnemonicTypeSelectionView {
    enum Event {
        case performBip39Action
        case performAlgo25Action
    }
}
