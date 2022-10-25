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
import MacaroonUtils
import UIKit

final class SwapAssetScreen:
    BaseScrollViewController,
    MacaroonForm.KeyboardControllerDataSource,
    SwapAssetAmountViewDelegate,
    SwapAssetFlowCoordinatorObserver {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private lazy var contextView = VStackView()
    private lazy var userAssetView = SwapAssetAmountView()
    private lazy var errorView = SwapErrorView()
    private lazy var quickActionsView = SwapQuickActionsView(theme.quickActions)
    private lazy var emptyPoolAssetView = SwapAssetSelectionEmptyView(theme: theme.emptyPoolAsset)
    private lazy var poolAssetView = SwapAssetAmountView()
    private lazy var swapActionView: LoadingButton = {
        let loadingIndicator = ViewLoadingIndicator()
        loadingIndicator.applyStyle(theme.swapActionIndicator)
        return LoadingButton(loadingIndicator: loadingIndicator)
    }()

    private lazy var balancePercentageValidator = SwapAvailableBalancePercentageValidator(dataController: dataController)
    private lazy var quoteValidator =  SwapAvailableBalanceQuoteValidator(account: dataController.account)

    private let currencyFormatter: CurrencyFormatter
    private let dataController: SwapAssetDataController
    private weak var swapAssetFlowCoordinator: SwapAssetFlowCoordinator?
    private var userAssetViewModel: SwapAssetAmountViewModel
    private var poolAssetViewModel: SwapAssetAmountViewModel?

    private let theme: SwapAssetScreenTheme = .init()

    init(
        dataController: SwapAssetDataController,
        coordinator: SwapAssetFlowCoordinator,
        configuration: ViewControllerConfiguration
    ) {
        self.currencyFormatter = CurrencyFormatter()
        self.dataController = dataController
        self.swapAssetFlowCoordinator = coordinator
        self.userAssetViewModel = SwapAssetAmountInViewModel(
            asset: dataController.userAsset,
            quote: nil,
            currency: configuration.sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        super.init(configuration: configuration)

        keyboardController.activate()
        swapAssetFlowCoordinator?.add(self)
    }

    deinit {
        keyboardController.deactivate()
        swapAssetFlowCoordinator?.remove(self)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        bindNavigationItemTitle()
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeAppearance(theme.background)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addBackground()
        addContext()
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

    private func validateFromQuote(
        _ quote: SwapQuote
    ) {
        quoteValidator.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .validated(let availableBalance):
                break
            case .failure(let error):
                switch error {
                case .assetInNotAvailable:
                    break
                case .assetOutNotAvailable:
                    break
                case .amountInNotAvailable:
                    break
                case .insufficientAlgoBalance:
                    break
                case .insufficientAssetBalance:
                    break
                case .unavailablePeraFee(let feeError):
                    break
                }
            }
        }

        quoteValidator.validateAvailableSwapBalance(
            quote,
            for: dataController.userAsset
        )
    }

    private func validateFromBalancePercentage(
        _ quote: SwapQuote
    ) {
        balancePercentageValidator.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .validated(let availableBalance):
                break
            case .failure(let error):
                switch error {
                case .assetInNotAvailable:
                    break
                case .assetOutNotAvailable:
                    break
                case .amountInNotAvailable:
                    break
                case .insufficientAlgoBalance:
                    break
                case .insufficientAssetBalance:
                    break
                case .unavailablePeraFee(let feeError):
                    break
                }
            }
        }

        balancePercentageValidator.validateAvailableSwapBalance(
            quote,
            for: dataController.userAsset
        )
    }
}

extension SwapAssetScreen {
    private func addBarButtons() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) {
            [weak self] in
            guard let self = self else { return }

            self.open(AlgorandWeb.tinymanSwap.link)
        }

        rightBarButtonItems = [infoBarButtonItem]
    }

    private func bindNavigationItemTitle() {
        title = "title-swap".localized
    }
}

extension SwapAssetScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)

        contextView.spacing = theme.contextSpacing
        contextView.snp.makeConstraints {
            $0.top == theme.contextTopInset
            $0.leading == theme.contextHorizontalInset
            $0.trailing == theme.contextHorizontalInset
        }

        addUserAsset()
        addError()
        addQuickActions()
        addEmptyPoolAsset()
        addPoolAsset()
    }

    private func addUserAsset() {
        userAssetView.customize(theme.userAsset)
        contextView.addArrangedSubview(userAssetView)

        userAssetView.startObserving(event: .didSelectAsset) {
            [weak self] in
            guard let self = self else { return }
            self.didTapUserAsset()
        }
    }

    private func addError() {
        errorView.customize(theme.error)
        
        contextView.addArrangedSubview(errorView)
        errorView.isHidden = true
    }

    private func addQuickActions() {
        contextView.addArrangedSubview(quickActionsView)

        quickActionsView.bind(SwapQuickActionsViewModel())

        quickActionsView.startObserving(event: .switchAssets) {
            print("Switch assets")
        }
        quickActionsView.startObserving(event: .adjustAmount) {
            [unowned self] in
            self.open(
                .adjustSwapAmount,
                by: .present
            )
        }
        quickActionsView.startObserving(event: .setMaxAmount) {
            print("set max amount")
        }

        contentView.attachSeparator(
            theme.quickActionsSeparator,
            to: quickActionsView
        )
    }

    private func addEmptyPoolAsset() {
        emptyPoolAssetView.customize()

        contextView.addArrangedSubview(emptyPoolAssetView)

        emptyPoolAssetView.startObserving(event: .didSelectAsset) {
            [weak self] in
            guard let self = self else { return }

            self.didTapPoolAsset()
        }
    }

    private func addPoolAsset() {
        poolAssetView.customize(theme.poolAsset)

        poolAssetView.isHidden = true
        contextView.addArrangedSubview(poolAssetView)

        poolAssetView.startObserving(event: .didSelectAsset) {
            [weak self] in
            guard let self = self else { return }
            self.didTapPoolAsset()
        }
    }

    private func addSwapAction() {
        swapActionView.customizeAppearance(theme.swapAction)

        contextView.addArrangedSubview(swapActionView)

        contentView.addSubview(swapActionView)
        swapActionView.contentEdgeInsets = theme.swapActionContentEdgeInsets
        swapActionView.snp.makeConstraints {
            $0.fitToHeight(theme.swapActionHeight)
            $0.top >= contextView.snp.bottom + theme.swapActionEdgeInsets.top
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
    func swapAssetFlowCoordinator(
        _ swapAssetFlowCoordinator: SwapAssetFlowCoordinator,
        didPublish event: SwapAssetFlowCoordinatorEvent
    ) {
        switch event {
        case .didSelectUserAsset(let asset):
            updateUserAsset(asset)
        case .didSelectPoolAsset(let asset):
            updatePoolAsset(asset)
        case .didApproveOptInToAsset: break
        }
    }

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

    @objc
    private func swap() {
        eventHandler?(.didTapSwap)
    }
}

extension SwapAssetScreen {
    private func getSwapQuote(
        for amount: UInt64
    ) {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willLoadQuote: self.updateUIWhenDataWillLoad()
            case .didLoadQuote(let quote): self.updateUIWhenDataDidLoad(quote)
            case .didFailToLoadQuote(let error): self.updateUIWhenDataDidFailToLoad(error)
            case .willLoadPeraFee: break
            case .didLoadPeraFee: break
            case .didFailToLoadPeraFee: break
            }
        }

        swapActionView.startLoading()
        dataController.loadQuote(swapAmount: amount)
    }

    private func updateUIWhenDataWillLoad() {
        
    }

    private func updateUIWhenDataDidLoad(
        _ swapQuote: SwapQuote
    ) {
        swapActionView.stopLoading()
        updateSwapActionUIWhenDataDidLoad(quote: swapQuote)
        updateUserAssetViewModel(quote: swapQuote)
        updateUserAssetSelectionUI()
        updatePoolAssetViewModel(quote: swapQuote)
        updatePoolAssetSelectionUI()
        hideError()
    }

    private func updateUIWhenDataDidFailToLoad(
        _ error: SwapAssetDataController.Error
    ) {
        swapActionView.stopLoading()
        showError(error.prettyDescription)
    }
}

extension SwapAssetScreen {
    private func updateSwapActionUIWhenDataDidLoad(
        quote: SwapQuote?
    ) {
        guard let quote else {
            swapActionView.isEnabled = false
            return
        }

        swapActionView.isEnabled =
            quote.amountIn != nil &&
            quote.assetOut != nil &&
            quote.assetOut != nil
    }

    private func hideError() {
        errorView.isHidden = true
    }

    private func showError(
        _ message: String
    ) {
        errorView.isHidden = false

        let viewModel = SwapAssetErrorViewModel(message)
        errorView.bindData(viewModel)
    }
}

extension SwapAssetScreen {
    private func didTapUserAsset() {
        eventHandler?(.didTapUserAsset)
    }

    private func updateUserAsset(
        _ asset: Asset,
        for quote: SwapQuote? = nil
    ) {
        dataController.userAsset = asset
        updateUserAssetViewModel(quote: quote)
        updateUserAssetSelectionUI()
    }

    private func updateUserAssetViewModel(
        quote: SwapQuote? = nil
    ) {
        userAssetViewModel = SwapAssetAmountInViewModel(
            asset: dataController.userAsset,
            quote: quote,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
    }

    private func updateUserAssetSelectionUI() {
        userAssetView.bindData(userAssetViewModel)
    }

    private func didTapPoolAsset() {
        eventHandler?(.didTapPoolAsset)
    }

    private func updatePoolAsset(
        _ asset: Asset,
        for quote: SwapQuote? = nil
    ) {
        dataController.poolAsset = asset
        updatePoolAssetViewModel(quote: quote)
        updatePoolAssetSelectionUI()
    }

    private func updatePoolAssetViewModel(
        quote: SwapQuote? = nil
    ) {
        guard let poolAsset = dataController.poolAsset else { return }

        poolAssetViewModel = SwapAssetAmountOutViewModel(
            asset: poolAsset,
            quote: quote,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
    }

    private func updatePoolAssetSelectionUI() {
        emptyPoolAssetView.isHidden = true
        poolAssetView.isHidden = false
        poolAssetView.bindData(poolAssetViewModel)
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
    /// <note>
    /// Request the new quote whent the user types an amount.
    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        didChangeTextIn textField: TextField
    ) {
        guard let input = textField.text,
              let inputAsDecimal = input.decimalAmount,
              !isTheInputDecimalSeparator(input) else {
            return
        }

        let inputAsFractionUnit = inputAsDecimal.toFraction(of: dataController.userAsset.decimals)
        getSwapQuote(for: inputAsFractionUnit)
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

    /// <note>
    /// Check whether the input is a numeric value.
    /// Limit number of decimal separator to 1.
    /// Limit number of decimals with respect to the current asset.
    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        shouldChangeCharactersIn textField: TextField,
        with range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let currentText = textField.text,
              let currentTextRange = Range(range, in: currentText) else {
            return true
        }

        let newText = currentText.replacingCharacters(in: currentTextRange, with: string)
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        let decimalSeparator = Locale.preferred.decimalSeparator ?? "."
        let numberOfDecimalSeparators = newText.components(separatedBy: decimalSeparator).count - 1

        let numberOfDecimals: Int
        if let dotIndex = newText.firstIndex(of: ".") {
            numberOfDecimals = newText.distance(
                from: dotIndex,
                to: newText.endIndex
            ) - 1
        } else {
            numberOfDecimals = 0
        }

        return
            isNumeric &&
            numberOfDecimalSeparators <= 1 &&
            numberOfDecimals <= dataController.userAsset.decimals
    }

    private func isTheInputDecimalSeparator(
        _ input: String
    ) -> Bool {
        let decimalSeparator = Locale.preferred.decimalSeparator ?? "."

        guard let lastCharacter = input.last else { return false }

        return String(lastCharacter) == decimalSeparator
    }
}

extension SwapAssetScreen {
    enum Event {
        case didTapUserAsset
        case didTapPoolAsset
        case didTapSwap
    }
}
