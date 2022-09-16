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

//   SwapAssetScreen.swift

import MacaroonForm
import MacaroonUIKit
import UIKit

final class SwapAssetScreen:
    BaseScrollViewController,
    MacaroonForm.KeyboardControllerDataSource,
    SwapAssetAmountViewDelegate {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private lazy var userAssetView = SwapAssetAmountView()
    private lazy var emptyPoolAssetView = SwapAssetSelectionEmptyView(theme: theme.emptyPoolAsset)
    private lazy var poolAssetView = SwapAssetAmountView()
    private lazy var swapActionView = MacaroonUIKit.Button()

    private var currentlyDisplayedPoolView: UIView?

    private let dataController: SwapAssetDataController
    private let theme: SwapAssetScreenTheme
    private var userAssetViewModel: SwapAssetAmountViewModel
    private var poolAssetViewModel: SwapAssetAmountViewModel?

    init(
        dataController: SwapAssetDataController,
        configuration: ViewControllerConfiguration,
        theme: SwapAssetScreenTheme = .init()
    ) {
        self.dataController = dataController
        self.theme = theme
        let userAssetViewModelDraft = SwapAssetAmountViewModelDraft(
            leftTitle: "transaction-detail-from".localized,
            rightTitle: "title-account-balance".localized,
            assetItem: dataController.getUserAssetItem(),
            isInputEditable: true
        )
        self.userAssetViewModel = SwapAssetAmountViewModel(userAssetViewModelDraft)
        super.init(configuration: configuration)

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        bindNavigationItemTitle()
    }

    override func prepareLayout() {
        super.prepareLayout()
        addUserAsset()
        addPoolAssetIfNeeded()
        addSwapAction()
    }

    override func setListeners() {
        super.setListeners()
        userAssetView.delegate = self
        poolAssetView.delegate = self
        performKeyboardActions()
    }

    override func bindData() {
        super.bindData()
        userAssetView.bindData(userAssetViewModel)

        if let poolAssetViewModel = poolAssetViewModel {
            poolAssetView.bindData(poolAssetViewModel)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUIWhenViewDidLayoutSubviews()
    }
}

extension SwapAssetScreen {
    private func addBarButtons() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) {
            [weak self] in
            guard let self = self else { return }

        }

        rightBarButtonItems = [infoBarButtonItem]
    }

    private func bindNavigationItemTitle() {
        title = "title-swap".localized
    }
}

extension SwapAssetScreen {
    private func addUserAsset() {
        userAssetView.customize(theme.userAsset)
        
        contentView.addSubview(userAssetView)
        userAssetView.fitToIntrinsicSize()
        userAssetView.snp.makeConstraints {
            $0.top == theme.userAssetTopInset
            $0.leading == theme.assetHorizontalInset
            $0.trailing == theme.assetHorizontalInset
        }
    }

    private func addPoolAssetIfNeeded() {
        if poolAssetViewModel == nil {
            addEmptyPoolAsset()
        } else {
            addPoolAsset()
        }
    }

    private func addEmptyPoolAsset() {
        emptyPoolAssetView.customize()

        contentView.addSubview(emptyPoolAssetView)
        emptyPoolAssetView.fitToIntrinsicSize()
        emptyPoolAssetView.snp.makeConstraints {
            $0.top == userAssetView.snp.bottom + theme.poolAssetTopInset
            $0.leading == theme.assetHorizontalInset
            $0.trailing == theme.assetHorizontalInset
        }

        emptyPoolAssetView.startObserving(event: .didSelectAsset) {
            [weak self] in
            guard let self = self else { return }

            self.openPoolAssetSelection()
        }

        currentlyDisplayedPoolView = emptyPoolAssetView
    }

    private func addPoolAsset() {
        poolAssetView.customize(theme.poolAsset)

        contentView.addSubview(poolAssetView)
        poolAssetView.fitToIntrinsicSize()
        poolAssetView.snp.makeConstraints {
            $0.top == userAssetView.snp.bottom + theme.poolAssetTopInset
            $0.leading == theme.assetHorizontalInset
            $0.trailing == theme.assetHorizontalInset
        }

        currentlyDisplayedPoolView = poolAssetView
    }

    private func addSwapAction() {
        guard let currentlyDisplayedPoolView = currentlyDisplayedPoolView else { return }

        swapActionView.customizeAppearance(theme.swapAction)

        contentView.addSubview(swapActionView)
        swapActionView.contentEdgeInsets = theme.swapActionContentEdgeInsets
        swapActionView.snp.makeConstraints {
            $0.top >= currentlyDisplayedPoolView.snp.bottom + theme.swapActionEdgeInsets.top
            $0.leading == theme.swapActionEdgeInsets.leading
            $0.trailing == theme.swapActionEdgeInsets.trailing

            let bottomInset =
                view.compactSafeAreaInsets.bottom +
                (navigationController ?? self).additionalSafeAreaInsets.bottom
                + theme.swapActionContentEdgeInsets.bottom
            $0.bottom == bottomInset
         }

        swapActionView.addTouch(
             target: self,
             action: #selector(swap)
         )

        swapActionView.isEnabled = false
    }

    private func updateUIWhenViewDidLayoutSubviews() {
        updateScreenWhenViewDidLayoutSubviews()
    }
}

extension SwapAssetScreen {
    private func performKeyboardActions() {
        keyboardController.performAlongsideWhenKeyboardIsShowing(animated: true) {
            [weak self] keyboard in
            guard let self = self else { return }
            self.updateSwapActionLayoutWhenKeyboardIsShowing(keyboard)
        }

        keyboardController.performAlongsideWhenKeyboardIsHiding(animated: true) {
            [weak self] keyboard in
            guard let self = self else { return }
            self.updateSwapActionLayoutWhenKeyboardIsHiding(keyboard)
        }
    }

    private func openPoolAssetSelection() {

    }

    @objc
    private func swap() {
        eventHandler?(.swap)
    }
}

extension SwapAssetScreen {
    private func getSwapQuote(
        for amount: Decimal
    ) {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willLoadData: self.updateUIWhenDataWillLoad()
            case .didLoadData(let quote): self.updateUIWhenDataDidLoad(quote)
            case .didFailToLoadData(let error): self.updateUIWhenDataDidFailToLoad(error)
            }
        }

        dataController.loadData(swapAmount: amount)
    }

    private func updateUIWhenDataWillLoad() {
        
    }

    private func updateUIWhenDataDidLoad(
        _ swapQuote: SwapQuote
    ) {
        bindUIData(swapQuote)
        /// <todo> Remove error if needed
    }

    private func updateUIWhenDataDidFailToLoad(
        _ error: SwapAssetDataController.Error
    ) {
        /// <todo> Handle error cases
    }

    private func bindUIData(
        _ swapQuote: SwapQuote
    ) {

    }
}

extension SwapAssetScreen {
    func keyboardController(
        _ keyboardController: MacaroonForm.KeyboardController,
        editingRectIn view: UIView
    ) -> CGRect? {
        return getEditingRectOfCurrentAmountInputField()
    }

    func bottomInsetOverKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return theme.swapActionContentEdgeInsets.bottom
    }

    func additionalBottomInsetOverKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return calculateEmptySpacingToScrollCurrentAmountInputFieldToTop()
    }

    func bottomInsetUnderKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return 0
    }

    func bottomInsetWhenKeyboardDidHide(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        /// <note>
        /// It doesn't scroll to the bottom during the transition to another screen. When the
        /// screen is back, it will show the keyboard again anyway.
        if isViewDisappearing {
            return scrollView.contentInset.bottom
        }

        return theme.swapActionContentEdgeInsets.bottom
    }

    func spacingBetweenEditingRectAndKeyboard(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return calculateSpacingToScrollCurrentAmountInputFieldToTop()
    }
}

extension SwapAssetScreen {
    private func calculateEmptySpacingToScrollCurrentAmountInputFieldToTop() -> CGFloat {
        guard let editingRectOfCurrentAmountInputField = getEditingRectOfCurrentAmountInputField() else {
            return 0
        }

        let editingOriginYOfCurrentAmountInputField = editingRectOfCurrentAmountInputField.minY
        let visibleHeight = view.bounds.height
        let minContentHeight =
            editingOriginYOfCurrentAmountInputField +
            visibleHeight
        let keyboardHeight = keyboardController.keyboard?.height ?? 0
        let contentHeight = scrollView.contentSize.height
        let maybeEmptySpacing =
            minContentHeight -
            contentHeight -
            keyboardHeight
        return max(maybeEmptySpacing, 0)
    }

    private func calculateMinEmptySpacingToScrollCurrentAmountInputFieldToTop() -> CGFloat {
        let visibleHeight = view.bounds.height
        let editingRectOfCurrentAmountInputField = getEditingRectOfCurrentAmountInputField()
        let editingHeightOfCurrentAmountInputField = editingRectOfCurrentAmountInputField?.height ?? 0
        return visibleHeight - editingHeightOfCurrentAmountInputField
    }

    private func calculateSpacingToScrollCurrentAmountInputFieldToTop() -> CGFloat {
        guard let editingRectOfCurrentAmountInputField = getEditingRectOfCurrentAmountInputField() else {
            return 8 // minSpacingBetweenSearchInputFieldAndKeyboard
        }

        let visibleHeight = view.bounds.height
        let editingHeightOfCurrentAmountInputField = editingRectOfCurrentAmountInputField.height
        let keyboardHeight = keyboardController.keyboard?.height ?? 0
        return
            visibleHeight -
            editingHeightOfCurrentAmountInputField -
            keyboardHeight
    }

    private func getEditingRectOfCurrentAmountInputField() -> CGRect? {
        if userAssetView.isFirstResponder {
            return userAssetView.frame
        }

        if poolAssetView.isFirstResponder {
            return poolAssetView.frame
        }

        return nil
    }

    private func updateSwapActionLayoutWhenKeyboardIsShowing(
        _ keyboard: MacaroonForm.Keyboard
    ) {
        swapActionView.snp.updateConstraints {
            var padding = keyboard.height + theme.swapActionContentEdgeInsets.bottom
            let bottomInsetUnderKeyboard =
                bottomInsetUnderKeyboardWhenKeyboardDidShow(
                    keyboardController
                )

            if bottomInsetUnderKeyboard > 0 {
                /// <note>
                /// Assume that the safe area bottom is added to `bottomInsetUnderKeyboard`.
                padding -= bottomInsetUnderKeyboard
            }

            $0.bottom == padding
        }
    }

    private func updateSwapActionLayoutWhenKeyboardIsHiding(
        _ keyboard: MacaroonForm.Keyboard
    ) {
        let bottomInsetUnderKeyboard =
            bottomInsetUnderKeyboardWhenKeyboardDidShow(
                keyboardController
            )

        /// <note>
        /// This is valid if the bottom inset under the keyboard is temporarily used.
        if bottomInsetUnderKeyboard > 0 {
            return
        }

        swapActionView.snp.updateConstraints {
            let bottomInset =
                view.compactSafeAreaInsets.bottom +
                (navigationController ?? self).additionalSafeAreaInsets.bottom
                + theme.swapActionContentEdgeInsets.bottom
            $0.bottom == bottomInset
        }
    }

    private func updateScreenWhenViewDidLayoutSubviews() {
        if keyboardController.isKeyboardVisible {
            return
        }

        let bottom = bottomInsetWhenKeyboardDidHide(keyboardController)
        scrollView.setContentInset(bottom: bottom)
    }
}

extension SwapAssetScreen {
    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        didChangeTextIn textField: TextField
    ) {
        guard let input = textField.text,
              let inputAsDecimal = Decimal(string: input) else {
                  return
              }

        getSwapQuote(for: inputAsDecimal)
    }

    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        didBeginEditingIn textField: TextField
    ) {

    }

    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        didEndEditingIn textField: TextField
    ) {

    }

    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        shouldChangeCharactersIn textField: TextField,
        with range: NSRange,
        replacementString string: String
    ) -> Bool {
        return true
    }
}

extension SwapAssetScreen {
    enum Event {
        case swap
    }
}
