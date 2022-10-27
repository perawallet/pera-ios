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
import MacaroonForm
import MacaroonUIKit
import UIKit

final class AdjustSwapAmountScreen:
    BaseScrollViewController,
    BottomSheetScrollPresentable,
    MacaroonForm.KeyboardControllerDataSource {
    /// <todo>
    /// EventHandler???
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    var modalBottomPadding: LayoutMetric {
        return bottomInsetUnderKeyboardWhenKeyboardDidShow(keyboardController)
    }

    let modalHeight: MacaroonUIKit.ModalHeight = .compressed

    private lazy var amountPercentageInputView =
        AdjustableSingleSelectionInputView(theme.amountPercentageInput)

    private lazy var amountPercentageInputViewModel =
        SwapAmountPercentageInputViewModel(percentage: dataStore.amountPercentage)

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private let dataStore: SwapAmountPercentageStore
    private let dataProvider: AdjustSwapAmountDataProvider

    private let theme: AdjustSwapAmountScreenTheme = .init()

    init(
        dataStore: SwapAmountPercentageStore,
        dataProvider: AdjustSwapAmountDataProvider,
        configuration: ViewControllerConfiguration
    ) {
        self.dataStore = dataStore
        self.dataProvider = dataProvider
        super.init(configuration: configuration)

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func configureNavigationBarAppearance() {
        navigationItem.title = "swap-amount-percentage-title".localized

        let doneItem = ALGBarButtonItem(kind: .doneGreen) {
            [unowned self] in
            self.commitPreferredAmountPercentage()
        }
        rightBarButtonItems = [ doneItem ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureKeyboardController()
        addUI()
    }
}

/// <mark>
/// MacaroonForm.KeyboardControllerDataSource
extension AdjustSwapAmountScreen {
    func bottomInsetUnderKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return keyboardController.keyboard?.height ?? 0
    }
}

extension AdjustSwapAmountScreen {
    private func configureKeyboardController() {
        keyboardController.performAlongsideWhenKeyboardIsShowing(animated: true) {
            [unowned self] _ in
            self.performLayoutUpdates(animated: false)
        }
    }
}

extension AdjustSwapAmountScreen {
    private func addUI() {
        addAmountPercentageInput()
    }

    private func addAmountPercentageInput() {
        contentView.addSubview(amountPercentageInputView)
        amountPercentageInputView.snp.makeConstraints {
            $0.top == theme.amountPercentageInputEdgeInsets.top
            $0.leading == theme.amountPercentageInputEdgeInsets.leading
            $0.bottom <= theme.amountPercentageInputEdgeInsets.bottom
            $0.trailing == theme.amountPercentageInputEdgeInsets.trailing
        }

        amountPercentageInputView.textInputFormatter = PercentageInputFormatter()
        amountPercentageInputView.bind(amountPercentageInputViewModel)

        amountPercentageInputView.addTarget(
            self,
            action: #selector(determineActionForPreferredAmountPercentage),
            for: .valueChanged
        )
    }
}

extension AdjustSwapAmountScreen {
    @objc
    private func determineActionForPreferredAmountPercentage() {
        switch amountPercentageInputView.value {
        case .option(let index):
            commitAmountPercentage(optionAt: index)
            eventHandler?(.didComplete)
        default:
            break
        }
    }

    private func commitPreferredAmountPercentage() {
        switch amountPercentageInputView.value {
        case .none: dataProvider.saveAmountPercentage(nil)
        case .custom(let text): commitAmountPercentage(customText: text)
        case .option(let index): commitAmountPercentage(optionAt: index)
        }

        eventHandler?(.didComplete)
    }

    private func commitAmountPercentage(customText: String) {
        let percentage = Float(customText).unwrap { CustomSwapAmountPercentage(value: $0) }
        dataProvider.saveAmountPercentage(percentage)
    }

    private func commitAmountPercentage(optionAt index: Int) {
        let percentage = amountPercentageInputViewModel.percentagesPreset[safe: index]
        dataProvider.saveAmountPercentage(percentage)
    }
}

extension AdjustSwapAmountScreen {
    enum Event {
        case didComplete
    }
}
