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

    private var draft = SetSlippageToleranceDraft()

    private var validationStatus = true

    private lazy var contextView = SelectorInputView()

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private let theme: SetSlippageToleranceScreenTheme

    typealias EventHandler = (Event) -> Void
    private let eventHandler: EventHandler

    init(
        theme: SetSlippageToleranceScreenTheme = .init(),
        eventHandler: @escaping EventHandler,
        configuration: ViewControllerConfiguration
    ) {
        self.theme = theme
        self.eventHandler = eventHandler
        super.init(configuration: configuration)

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func linkInteractors() {
        super.linkInteractors()

        contextView.textInputView.validator = draft.slippageToleranceValidator
        contextView.textInputView.editingDelegate = self
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

        let viewModel = SlippageSelectorInputViewModel(options: draft.optionValues)
        contextView.bindData(viewModel)
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

            let inputIndex = self.contextView.getSelectedIndex()

            if inputIndex != -1 {
                self.eventHandler(.setSlippage(self.draft.optionValues[inputIndex]))
                self.dismissScreen()
                return
            }

            if let input = self.contextView.textInputView.text,
               let inputDecimal = Decimal(string: input),
               self.validationStatus {
                self.eventHandler(.setSlippage(inputDecimal))
                self.dismissScreen()
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

            contextView.snp.updateConstraints {
                $0.bottom == keyboardHeight - view.safeAreaBottom
            }
            performLayoutUpdates()
            return
        }

        contextView.snp.updateConstraints {
            $0.bottom == 0
        }
        performLayoutUpdates()
    }
}

extension SetSlippageToleranceScreen: FormInputFieldViewEditingDelegate {
    func formInputFieldViewDidBeginEditing(_ view: FormInputFieldView) {}

    func formInputFieldViewDidEdit(_ view: FormInputFieldView) {
        contextView.resetSelectedOption()

        setSingleDecimalSeparator()
        setInputNumberWithThreeFractions()
        setTextInputState()
    }

    func formInputFieldViewDidEndEditing(_ view: FormInputFieldView) {}

    private func setSingleDecimalSeparator() {
        guard let text = contextView.textInputView.text,
              let lastChar = text.last,
              let decimalSeparator = Locale.current.decimalSeparator
        else {
            return
        }
        
        let lastCharacterOfInput = String([lastChar])

        if lastCharacterOfInput == decimalSeparator {
            let numberOfDecimalSeparator = text.filter({
                $0 == lastChar
            }).count
            
            if numberOfDecimalSeparator > 1 {
                contextView.textInputView.text = String(text.dropLast())
            }
        }
    }

    private func setInputNumberWithThreeFractions() {
        guard let text = contextView.textInputView.text,
              let decimalSeparator = Locale.current.decimalSeparator
        else {
            return
        }

        let components = text.components(separatedBy: decimalSeparator)

        guard let decimalPart = components.last,
              components.count > 1
        else {
            return
        }
        
        let numberOfFractions = 3

        if decimalPart.count > numberOfFractions {
            contextView.textInputView.text = String(text.dropLast())
        }
    }

    private func setTextInputState() {
        let validation = draft.validateSlippageTolerance(contextView.textInputView.text)

        switch validation {
        case .success:
            contextView.textInputView.inputState = .focus
            validationStatus = true
        case .failure(let error):
            contextView.textInputView.inputState = .invalid(error)
            validationStatus = false
        }
    }
}

extension SetSlippageToleranceScreen {
    enum Event {
        case setSlippage(Decimal)
    }
}
