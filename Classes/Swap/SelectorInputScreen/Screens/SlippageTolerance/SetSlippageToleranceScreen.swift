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

//   SetSlippageToleranceScreen.swift

import UIKit
import MacaroonUIKit
import MacaroonForm
import MacaroonBottomSheet
import MacaroonUtils

final class SetSlippageToleranceScreen:
    BaseScrollViewController,
    BottomSheetScrollPresentable,
    MacaroonForm.KeyboardControllerDataSource {
    var modalHeight: ModalHeight {
        return .compressed
    }

    private lazy var contextView = SelectorInputView()

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private let theme: SetSlippageToleranceScreenTheme

    init(
        theme: SetSlippageToleranceScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.theme = theme
        super.init(configuration: configuration)

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        addBarButtons()
        bindNavigationItemTitle()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addBackground(theme)
        addContext(theme)
    }

    override func bindData() {
        super.bindData()

        contextView.bindData(SlippageSelectorInputViewModel())
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateLayoutWithKeyboardAppearance()
    }
}

extension SetSlippageToleranceScreen {
    private func addBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .doneGreen) {
            [weak self] in
            guard let self = self else {
                return
            }
        }
        rightBarButtonItems = [doneBarButtonItem]
    }
    private func bindNavigationItemTitle() {
        navigationItem.largeTitleDisplayMode = .never
        title = "swap-slippage-title".localized
    }
}

extension SetSlippageToleranceScreen {
    private func addBackground(_ theme: SetSlippageToleranceScreenTheme) {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    private func addContext(_ theme: SetSlippageToleranceScreenTheme) {
        contextView.customize(theme.contextView)

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension SetSlippageToleranceScreen {
    private func updateLayoutWithKeyboardAppearance() {
        if keyboardController.isKeyboardVisible {
            guard let keyboardHeight = keyboardController.keyboard?.height else {
                return
            }

            contextView.setBottomPaddingForKeyboard(keyboardHeight)
            performLayoutUpdates()
            return
        }

        contextView.setBottomPadding()
        performLayoutUpdates()
    }
}
