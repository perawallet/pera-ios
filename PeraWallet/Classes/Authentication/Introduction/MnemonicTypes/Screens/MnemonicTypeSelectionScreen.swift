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

//   MnemonicTypeSelectionScreen.swift

import UIKit

final class MnemonicTypeSelectionScreen: BaseViewController {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?
    private lazy var mnemonicTypeSelectionView = MnemonicTypeSelectionView()
    private lazy var theme = Theme()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = String(localized: "mnemonic-types-screen-title")
    }

    override func bindData() {
        let bip39ViewModel = MnemonicTypeViewModel(
            title: String(localized: "mnemonic-types-bip39-title"),
            detail: String(localized: "mnemonic-types-bip39-detail"),
            info: String(localized: "mnemonic-types-bip39-info"),
            isRecommended: true
        )
        let algo25ViewModel = MnemonicTypeViewModel(
            title: String(localized: "mnemonic-types-algo25-title"),
            detail: String(localized: "mnemonic-types-algo25-detail"),
            info: String(localized: "mnemonic-types-algo25-info"),
            isRecommended: false
        )
        mnemonicTypeSelectionView.bindData(
            .init(
                bip39ViewModel: bip39ViewModel,
                algo25ViewModel: algo25ViewModel
            )
        )
        
        
        mnemonicTypeSelectionView.startObserving(event: .performBip39Action) {
            [weak self] in
            guard let self else { return }
            dismissScreen { [weak self] in
                guard let self else { return }
                self.eventHandler?(.didSelectBip39)
            }
        }
        
        mnemonicTypeSelectionView.startObserving(event: .performAlgo25Action) {
            [weak self] in
            guard let self else { return }
            dismissScreen { [weak self] in
                guard let self else { return }
                self.eventHandler?(.didSelectAlgo25)
            }
        }

    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func prepareLayout() {
        mnemonicTypeSelectionView.customize(theme.mnemonicTypeSelectionViewTheme)

        prepareWholeScreenLayoutFor(mnemonicTypeSelectionView)
    }
}

extension MnemonicTypeSelectionScreen {
    enum Event {
        case didSelectBip39
        case didSelectAlgo25
    }
}
