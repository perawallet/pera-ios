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

typealias SwapAssetDataStore = SwapAmountPercentageStore

final class SwapAssetScreen:
    BaseScrollViewController,
    MacaroonForm.KeyboardControllerDataSource,
    SwapAssetAmountViewDelegate,
    SwapAmountPercentageStoreObserver,
    SwapAssetFlowCoordinatorObserver {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private lazy var navigationTitleView = AccountNameTitleView()
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

    private lazy var swapAssetValueFormatter = SwapAssetValueFormatter()

    private let currencyFormatter: CurrencyFormatter
    private let dataController: SwapAssetDataController
    private weak var swapAssetFlowCoordinator: SwapAssetFlowCoordinator?
    private let copyToClipboardController: CopyToClipboardController
    private var userAssetViewModel: SwapAssetAmountViewModel
    private var poolAssetViewModel: SwapAssetAmountViewModel?

    private var currentInputAsInt: UInt64? {
        if let userAmountString = userAssetView.currentAmount,
           let amountInDecimal = Decimal(string: userAmountString) {
            return amountInDecimal.toFraction(of: dataController.userAsset.decimals)
        }

        return nil
    }

    private var currentOutputAsInt: UInt64? {
        if let poolAsset = dataController.poolAsset,
           let poolAmountString = poolAssetView.currentAmount,
           let amountOutDecimal = Decimal(string: poolAmountString) {
            return amountOutDecimal.toFraction(of: poolAsset.decimals)
        }

        return nil
    }

    private let dataStore: SwapAssetDataStore

    private let theme: SwapAssetScreenTheme = .init()

    init(
        dataStore: SwapAssetDataStore,
        dataController: SwapAssetDataController,
        coordinator: SwapAssetFlowCoordinator,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataStore = dataStore
        self.dataController = dataController
        self.swapAssetFlowCoordinator = coordinator
        self.copyToClipboardController = copyToClipboardController
        self.currencyFormatter = CurrencyFormatter()
        self.userAssetViewModel = SwapAssetAmountInViewModel(
            asset: dataController.userAsset,
            quote: nil,
            currency: configuration.sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        super.init(configuration: configuration)

        dataStore.add(self)
        swapAssetFlowCoordinator?.add(self)

        keyboardController.activate()
    }

    deinit {
        dataStore.remove(self)
        swapAssetFlowCoordinator?.remove(self)

        keyboardController.deactivate()
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        addNavigationTitle()
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
}

extension SwapAssetScreen {
    private func addNavigationTitle() {
        navigationTitleView.customize(theme.navigationTitle)

        navigationItem.titleView = navigationTitleView

        let recognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(copyAccountAddress(_:))
        )
        navigationTitleView.addGestureRecognizer(recognizer)

        bindNavigationTitle()
    }

    private func bindNavigationTitle() {
        let draft = AccountNameTitleDraft(
            title: "title-swap".localized,
            account: dataController.account
        )

        let viewModel = AccountNameTitleViewModel(draft)
        navigationTitleView.bindData(viewModel)
    }

    private func addBarButtons() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) {
            [weak self] in
            guard let self = self else { return }

            self.open(AlgorandWeb.tinymanSwap.link)
        }

        rightBarButtonItems = [infoBarButtonItem]
    }
}

extension SwapAssetScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)
        contextView.spacing = theme.contextSpacing
        contextView.directionalLayoutMargins = theme.contextContentEdgeInsets
        contextView.isLayoutMarginsRelativeArrangement = true
        contextView.snp.makeConstraints {
            $0.top == theme.contextTopInset
            $0.leading == 0
            $0.trailing == 0
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
        quickActionsView.setLeftQuickActionsHidden(true)
        quickActionsView.setRightQuickActionsHidden(true)

        quickActionsView.startObserving(event: .switchAssets) {
            [unowned self] in
            self.switchAssets()
        }
        quickActionsView.startObserving(event: .adjustAmount) {
            [unowned self] in
            self.eventHandler?(.adjustAmount)
        }
        quickActionsView.startObserving(event: .setMaxAmount) {
            print("set max amount")
        }

        contextView.attachSeparator(
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
            case .didLoadQuote(let quote): self.validateFromQuote(quote)
            case .didFailToLoadQuote(let error): self.updateUIWhenDataDidFailToLoad(error)
            }
        }

        dataController.loadQuote(swapAmount: amount)
    }

    private func updateUIWhenDataWillLoad() {
        swapActionView.startLoading()
    }

    private func validateFromQuote(
        _ quote: SwapQuote
    ) {
        var quoteValidator = SwapAvailableBalanceQuoteValidator(
            account: dataController.account,
            quote: quote
        )

        quoteValidator.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .validated:
                self.updateUIWhenDataDidLoad(quote)
            case .failure(let error):
                switch error {
                case .amountInNotAvailable:
                    self.showError("swap-asset-not-available".localized)
                case .insufficientAlgoBalance(let minBalance):
                    self.showInsufficientAlgoBalanceErrorForQuoteValidation(minBalance)
                case .insufficientAssetBalance(let minBalance):
                    self.showInsufficientAssetBalanceErrorForQuoteValidation(
                        quote: quote,
                        minBalance: minBalance
                    )
                case .unavailablePeraFee: break
                }
            }
        }

        quoteValidator.validateAvailableSwapBalance()
    }

    private func updateUIWhenDataDidFailToLoad(
        _ error: SwapAssetDataController.Error
    ) {
        showError(error.prettyDescription)
    }
}

extension SwapAssetScreen {
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

    private func updateSwapActionUIWhenDataDidLoad(
        quote: SwapQuote
    ) {
        swapActionView.isEnabled =
            quote.amountIn != nil &&
            quote.assetOut != nil &&
            quote.assetOut != nil
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

    private func updateQuickActions() {
        if let poolAsset = dataController.poolAsset {
            if let poolAssetInAccount = dataController.account[poolAsset.id],
               poolAssetInAccount.amount > 0 {
                quickActionsView.setLeftQuickActionsHidden(false)
            } else {
                quickActionsView.setLeftQuickActionsHidden(true)
            }

            quickActionsView.setRightQuickActionsHidden(false)
        }
    }

    private func showInsufficientAlgoBalanceErrorForQuoteValidation(
        _ minBalance: UInt64
    ) {
        guard let amountText = swapAssetValueFormatter.getFormattedAlgoAmount(
            decimalAmount: minBalance.toAlgos,
            currencyFormatter: currencyFormatter
        ) else {
            swapActionView.stopLoading()
            return
        }

        showError("swap-asset-algo-min-balance-error".localized(params: amountText))
    }

    private func showInsufficientAssetBalanceErrorForQuoteValidation(
        quote: SwapQuote,
        minBalance: UInt64
    ) {
        guard let assetIn = quote.assetIn,
              let amountText = swapAssetValueFormatter.getFormattedAssetAmount(
                decimalAmount: swapAssetValueFormatter.getDecimalAmount(of: minBalance, for: assetIn),
                currencyFormatter: currencyFormatter,
                maximumFractionDigits: assetIn.decimals
              ) else {
            swapActionView.stopLoading()
            return
        }

        let assetDisplayValue = swapAssetValueFormatter.getAssetDisplayName(assetIn)
        showError("swap-asset-min-balance-error".localized(params: assetDisplayValue, amountText))
    }

    private func showError(
        _ message: String
    ) {
        swapActionView.stopLoading()
        swapActionView.isEnabled = false

        errorView.isHidden = false
        let viewModel = SwapAssetErrorViewModel(message)
        errorView.bindData(viewModel)
    }

    private func hideError() {
        errorView.isHidden = true
    }
}

extension SwapAssetScreen {
    @objc
    private func copyAccountAddress(
        _ recognizer: UILongPressGestureRecognizer
    ) {
        if recognizer.state == .began {
            copyToClipboardController.copyAddress(dataController.account)
        }
    }

    private func switchAssets() {
        guard let poolAsset = dataController.poolAsset else { return }

        dataController.poolAsset = dataController.userAsset
        dataController.userAsset = poolAsset

        if let currentOutputAsInt {
            if currentOutputAsInt == 0 {
                updateInput(nil)
            }

            getSwapQuote(for: currentOutputAsInt)
        }

        updateUserAssetViewModel()
        updateUserAssetSelectionUI()
        updatePoolAssetViewModel()
        updatePoolAssetSelectionUI()
    }

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
        updateQuickActions()
        getNewSwapQuoteAfterAssetUpdateIfNeeded()
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
        updateQuickActions()
        getNewSwapQuoteAfterAssetUpdateIfNeeded()
    }

    private func getNewSwapQuoteAfterAssetUpdateIfNeeded() {
        if let currentInputAsInt,
           currentInputAsInt > 0 {
            getSwapQuote(for: currentInputAsInt)
        }
    }
}

extension SwapAssetScreen {
    private func validateFromBalancePercentage(
        _ amount: UInt64
    ) {
        var balancePercentageValidator = SwapAvailableBalancePercentageValidator(
            account: dataController.account,
            asset: dataController.userAsset,
            amount: amount,
            api: api!
        )

        balancePercentageValidator.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .validated(let availableBalance):
                self.getSwapQuote(for: availableBalance)
            case .failure(let error):
                switch error {
                case .amountInNotAvailable: break
                case .insufficientAlgoBalance(let minBalance):
                    self.updateInput(minBalance)
                    self.showError("swap-asset-min-balance-error-without-amount".localized)
                case .insufficientAssetBalance(let minBalance):
                    self.updateInput(minBalance)
                    self.showError("swap-asset-min-balance-error-fee".localized)
                case .unavailablePeraFee(let feeError):
                    self.showError(feeError?.localizedDescription ?? "swap-asset-fee-unavailable-error".localized)
                }
            }
        }

        balancePercentageValidator.validateAvailableSwapBalance()
    }

    private func updateInput(
        _ input: UInt64?
    ) {
        guard let input else {
            userAssetView.updateInput(nil)
            return
        }

        let assetDecoration = AssetDecoration(asset: dataController.userAsset)
        let decimalAmount = swapAssetValueFormatter.getDecimalAmount(of: input, for: assetDecoration)

        if decimalAmount == 0 {
            userAssetView.updateInput(nil)
            return
        }

        guard let amountText = swapAssetValueFormatter.getFormattedAssetAmount(
                decimalAmount: decimalAmount,
                currencyFormatter: currencyFormatter,
                maximumFractionDigits: assetDecoration.decimals
              ) else {
            swapActionView.stopLoading()
            return
        }

        userAssetView.updateInput(amountText)
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
        guard let input = textField.text else { return }

        if input.isEmpty {
            getSwapQuote(for: 0)
            return
        }

        if isTheInputDecimalSeparator(input) {
            return
        }

        guard let inputAsDecimal = input.decimalAmount else { return }

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

/// <mark>
/// SwapAmountPercentageStoreObserver
extension SwapAssetScreen {
    func swapAmountPercentageDidChange() {
        guard let amountPercentage = dataStore.amountPercentage else { return }

        let amount = getAmountFromPercentage(amountPercentage.value).toFraction(of: dataController.userAsset.decimals)

        if dataController.poolAsset == nil {
            updateInput(amount)
            return
        }

        validateFromBalancePercentage(amount)
    }

    private func getAmountFromPercentage(
        _ percentage: Decimal
    ) -> Decimal {
        if dataController.userAsset.isAlgo {
            return dataController.account.algo.amount.toAlgos * percentage
        }

        let userAsset = AssetDecoration(asset: dataController.userAsset)
        guard let assetBalance = dataController.account[userAsset.id]?.amount else {
            return 0
        }

        let decimalValue = swapAssetValueFormatter.getDecimalAmount(
            of: assetBalance,
            for: userAsset
        )

        return decimalValue * percentage
    }
}

extension SwapAssetScreen {
    enum Event {
        case didTapUserAsset
        case adjustAmount
        case didTapPoolAsset
        case didTapSwap
    }
}
