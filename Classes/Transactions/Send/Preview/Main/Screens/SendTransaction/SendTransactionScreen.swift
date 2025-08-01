// Copyright 2022-2025 Pera Wallet, LDA

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
//   SendTransactionScreen.swift


import Foundation
import UIKit
import SnapKit
import MagpieHipo
import Alamofire
import MacaroonUIKit
import MacaroonUtils

final class SendTransactionScreen: BaseViewController {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private(set) lazy var modalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToEditNote = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToInsufficientAlgoBalance = BottomSheetTransition(presentingViewController: self)

    private lazy var navigationTitleView = AccountNameTitleView()
    private lazy var nextButton = Button()
    private lazy var assetItemCanvasView = TripleShadowView()
    private lazy var assetItemView = PrimaryListItemView()
    private lazy var collectibleAssetItemView = CollectibleListItemView()
    private lazy var numpadView = NumpadView(mode: .decimal)
    private lazy var noteButton = Button()
    private lazy var maxButton = Button()
    private lazy var currencyValueLabel = UILabel()
    private lazy var valueLabel = UILabel()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let theme = Theme()
    private var draft: SendTransactionDraft
    private let copyToClipboardController: CopyToClipboardController

    private var transactionParams: TransactionParams?

    private var _amount: String = "0"
    private var amount: String {
        get { _amount }
        set { _amount = newValue.components(separatedBy: .whitespacesAndNewlines).joined() }
    }
    private var isAmountResetted: Bool = true

    private lazy var amountValidator = TransactionAmountValidator(account: draft.from)

    private var note: String? {
        didSet {
            if draft.lockedNote != nil {
                noteButton.setTitle(String(localized: "send-transaction-show-note-title"), for: .normal)
                return
            }

            if !note.isNilOrEmpty {
                noteButton.setTitle(String(localized: "send-transaction-edit-note-title"), for: .normal)
            } else {
                noteButton.setTitle(String(localized: "send-transaction-add-note-title"), for: .normal)
            }
        }
    }

    private var isMaxTransaction: Bool {
        guard let decimalAmount = amount.decimalAmount else {
            return false
        }
        return draft.from.algo.amount == decimalAmount.toMicroAlgos
    }

    private var transactionSendController: TransactionSendController?

    init(
        draft: SendTransactionDraft,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        self.copyToClipboardController = copyToClipboardController
        self.note = draft.lockedNote ?? draft.note
        super.init(configuration: configuration)

        guard let amount = draft.amount else {
            return
        }

        switch draft.transactionMode {
        case .algo:
            self.amount = amount.toNumberStringWithSeparatorForLabel ?? "0"
        case .asset(let asset):
            self.amount = amount.toNumberStringWithSeparatorForLabel(fraction: asset.decimals) ?? "0"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getTransactionParams()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isViewFirstAppeared {
            presentTransactionTutorialIfNeeded()
        }
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = theme.backgroundColor

        if draft.fractionCount <= 0 {
            numpadView.leftButtonIsHidden = true
        }
    }

    override func configureNavigationBarAppearance() {
        addNavigationTitle()
        addNavigationActions()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addNextButton()
        addAssetItem()
        addNumpad()
        addButtons()
        addLabels()
    }

    override func bindData() {
        super.bindData()

        bindAmount()

        self.note = draft.lockedNote ?? draft.note
    }

    override func linkInteractors() {
        super.linkInteractors()

        numpadView.linkInteractors()
        numpadView.delegate = self

        maxButton.addTarget(self, action: #selector(didTapMax), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        noteButton.addTarget(self, action: #selector(didTapNote), for: .touchUpInside)
    }
}

extension SendTransactionScreen {
    private func presentTransactionTutorialIfNeeded() {
        let transactionTutorialStorage = TransactionTutorialStorage()

        if transactionTutorialStorage.isTransactionTutorialDisplayed {
            return
        }

        transactionTutorialStorage.setTransactionTutorialDisplayed()

        displayTransactionTutorial(isInitialDisplay: true)
    }
}

extension SendTransactionScreen {
    private func bindAmount() {
        let amountValue = self.amount.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        var showingValue = ""

        valueLabel.customizeAppearance(theme.valueLabelStyle)

        if let decimalStrings = amountValue.decimalStrings() {
            switch draft.transactionMode {
            case .algo:
                showingValue = (amountValue.replacingOccurrences(of: decimalStrings, with: "")
                    .decimalAmount?.toNumberStringWithSeparatorForLabel ?? amountValue)
                    .appending(decimalStrings)
            case .asset(let asset):
                showingValue = (amountValue.replacingOccurrences(of: decimalStrings, with: "")
                    .decimalAmount?.toNumberStringWithSeparatorForLabel(fraction: asset.decimals) ?? amountValue)
                    .appending(decimalStrings)
            }
        } else {
            showingValue = amountValue.decimalAmount?.toNumberStringWithSeparatorForLabel ?? amountValue

            if self.amount.decimal.number.intValue == 0 && isAmountResetted {
                if let string = self.amount.decimal.toFractionStringForLabel(fraction: 2) {
                    showingValue = string
                }
                valueLabel.customizeAppearance(theme.disabledValueLabelStyle)
            }
        }

        valueLabel.text = showingValue

        bindCurrencyAmount(amountValue)
    }
    
    private func bindCurrencyAmount(_ amountValue: String) {
        guard let amount = amountValue.decimalAmount else {
            currencyValueLabel.text = nil
            return
        }

        let currency = sharedDataController.currency

        switch draft.transactionMode {
        case .algo:
            guard let currencyValue = currency.fiatValue else {
                currencyValueLabel.text = nil
                return
            }

            do {
                let rawCurrency = try currencyValue.unwrap()

                let exchanger = CurrencyExchanger(currency: rawCurrency)
                let amountInCurrency = try exchanger.exchangeAlgo(amount: amount)

                currencyFormatter.formattingContext = .standalone()
                currencyFormatter.currency = rawCurrency

                currencyValueLabel.text = currencyFormatter.format(amountInCurrency)
            } catch {
                currencyValueLabel.text = nil
            }
        case let .asset(asset):
            guard let currencyValue = currency.primaryValue else {
                currencyValueLabel.text = nil
                return
            }

            do {
                let rawCurrency = try currencyValue.unwrap()

                let exchanger = CurrencyExchanger(currency: rawCurrency)
                let amountInCurrency = try exchanger.exchange(
                    asset,
                    amount: amount
                )

                currencyFormatter.formattingContext = .standalone()
                currencyFormatter.currency = rawCurrency

                currencyValueLabel.text = currencyFormatter.format(amountInCurrency)
            } catch {
                currencyValueLabel.text = nil
            }
        }
    }
}

extension SendTransactionScreen {
    private func displayTransactionTutorial(isInitialDisplay: Bool) {
        modalTransition.perform(
            .transactionTutorial(
                isInitialDisplay: isInitialDisplay
            ),
            by: .presentWithoutNavigationController
        )
    }
}

// MARK: - Layout
extension SendTransactionScreen {
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
        let draft = SendTransactionAccountNameTitleDraft(
            transactionMode: draft.transactionMode,
            account: draft.from
        )
        let viewModel = AccountNameTitleViewModel(draft)
        navigationTitleView.bindData(viewModel)
    }

    private func addNavigationActions() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) {
            [unowned self] in
            self.displayTransactionTutorial(isInitialDisplay: false)
        }

        rightBarButtonItems = [ infoBarButtonItem ]
    }

    private func addNextButton() {
        nextButton.customize(theme.nextButtonStyle)
        nextButton.setTitle(String(localized: "title-next"), for: .normal)

        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(theme.defaultBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.defaultLeadingInset)
            make.height.equalTo(theme.nextButtonHeight)
        }
    }

    private func addAssetItem() {
        let isCollectible = draft.asset is CollectibleAsset
        let itemView = isCollectible ? makeCollectibleAssetItemView() : makeAssetItemView()

        assetItemCanvasView.drawAppearance(shadow: theme.accountContainerFirstShadow)
        assetItemCanvasView.drawAppearance(secondShadow: theme.accountContainerSecondShadow)
        assetItemCanvasView.drawAppearance(thirdShadow: theme.accountContainerThirdShadow)

        view.addSubview(assetItemCanvasView)
        assetItemCanvasView.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(theme.defaultBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.defaultLeadingInset)
        }

        assetItemCanvasView.addSubview(itemView)
        itemView.snp.makeConstraints { make in
            make.setPaddings(theme.accountPaddings)
        }
    }

    private func makeAssetItemView() -> PrimaryListItemView {
        let view = PrimaryListItemView()
        view.customize(AssetListItemTheme())
        let viewModel = makeAssetItemViewModel()
        view.bindData(viewModel)
        return view
    }

    private func makeAssetItemViewModel() -> PrimaryListItemViewModel {
        let currency = sharedDataController.currency

        let viewModel: PrimaryListItemViewModel

        switch draft.transactionMode {
        case .algo:
            let algoAssetItem = AssetItem(
                asset: draft.from.algo,
                currency: currency,
                currencyFormatter: currencyFormatter,
                currencyFormattingContext: .standalone(),
                isAmountHidden: false
            )
            viewModel = AssetListItemViewModel(algoAssetItem)
        case .asset(let asset):
            let assetItem = AssetItem(
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter,
                currencyFormattingContext: .standalone(),
                isAmountHidden: false
            )
            viewModel = AssetListItemViewModel(assetItem)
        }

        return viewModel
    }

    private func makeCollectibleAssetItemView() -> CollectibleListItemView {
        let view = CollectibleListItemView()
        view.customize(CollectibleListItemViewTheme())
        let item = CollectibleAssetItem(
            account: draft.from,
            asset: draft.asset as! CollectibleAsset,
            amountFormatter: .init()
        )
        let viewModel = CollectibleListItemViewModel(item: item)
        view.bindData(viewModel)
        return view
    }

    private func addNumpad() {
        numpadView.customize(TransactionNumpadViewTheme())
        numpadView.deleteButtonIsHidden = self.amount == "0" || draft.isOptingOut
        numpadView.isUserInteractionEnabled = !draft.isOptingOut

        view.addSubview(numpadView)
        numpadView.snp.makeConstraints { make in
            make.bottom.equalTo(assetItemCanvasView.snp.top).offset(theme.numpadBottomInset)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func addButtons() {
        let stackView = HStackView()
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = theme.buttonsSpacing

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(numpadView.snp.top).offset(theme.buttonsBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.buttonsLeadingInset)
            make.height.equalTo(theme.buttonsHeight)
        }

        noteButton.setTitle(String(localized: "send-transaction-add-note-title"), for: .normal)
        maxButton.setTitle(String(localized: "send-transaction-max-button-title"), for: .normal)

        maxButton.customize(TransactionShadowButtonTheme())
        noteButton.customize(TransactionShadowButtonTheme())

        stackView.addArrangedSubview(noteButton)
        stackView.addArrangedSubview(maxButton)

        maxButton.isHidden = draft.isOptingOut
    }

    private func addLabels() {
        let labelStackView = VStackView()
        labelStackView.alignment = .center
        labelStackView.distribution = .equalCentering

        currencyValueLabel.customizeAppearance(theme.currencyValueLabelStyle)
        valueLabel.customizeAppearance(theme.disabledValueLabelStyle)

        view.addSubview(labelStackView)
        labelStackView.snp.makeConstraints { make in
            make.height.equalTo(theme.labelsContainerHeight)
            make.bottom.equalTo(maxButton.snp.top).offset(theme.labelsContainerBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.defaultLeadingInset)
        }

        labelStackView.addArrangedSubview(valueLabel)
        labelStackView.addArrangedSubview(currencyValueLabel)
    }
}

// MARK: - Actions
extension SendTransactionScreen {
    @objc
    private func didTapNext() {
        let validation = validate(value: amount)

        switch validation {
        case .success:
            handleSuccessAmountValidation()
        case .failure(let validationError):
            handleFailureAmountError(validationError)
        }
    }

    @objc
    private func didTapMax() {
        numpadView.deleteButtonIsHidden = false

        switch draft.transactionMode {
        case .algo:
            self.amount = draft.from.algo.amount.toAlgos.toNumberStringWithSeparatorForLabel ?? "0"
        case .asset(let asset):
            self.amount = asset.amountWithFraction.toNumberStringWithSeparatorForLabel(fraction: asset.decimals) ?? "0"
        }
        isAmountResetted = false
        bindAmount()
    }

    @objc
    private func didTapNote() {
        let isLocked = draft.lockedNote != nil
        let editNote = draft.lockedNote ?? draft.note

        let screen: Screen = .editNote(
            note: editNote,
            isLocked: isLocked,
            delegate: self
        )

        transitionToEditNote.perform(
            screen,
            by: .present
        )
    }

    private func didEditNote(note: String?) {
        self.note = note
        self.draft.updateNote(note)
    }

    private func redirectToPreview(_ previewDraft: SendTransactionDraft) {
        loadingController?.startLoadingWithMessage(String(localized: "title-loading"))

        transactionSendController = TransactionSendController(
            draft: previewDraft,
            api: api!,
            analytics: analytics
        )

        transactionSendController?.delegate = self
        transactionSendController?.validate()
    }

    @objc
    private func copyAccountAddress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            copyToClipboardController.copyAddress(draft.from)
        }
    }
}

// MARK: - Validation
extension SendTransactionScreen {
    private func handleSuccessAmountValidation() {
        draft.amount = amount.decimalAmount

        if draft.hasReceiver {
            redirectToPreview(draft)
            return
        }

        let screen = open(
            .sendAssetReceiverAccountSelectionList(
                asset: draft.asset,
                addressInputViewText: nil
            ),
            by: .push
        ) as? ReceiverAccountSelectionListScreen
        screen?.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            var nextDraft = self.draft

            switch event {
            case .didSelectAccount(let account):
                nextDraft.toAccount = account
            case .didSelectContact(let contact):
                nextDraft.toContact = contact
            case .didSelectNameService(let nameService):
                nextDraft.toAccount = nameService.account.value
                nextDraft.toNameService = nameService
            }

            self.redirectToPreview(nextDraft)
        }
    }

    private func handleFailureAmountError(_ validation: TransactionAmountValidationError) {
        switch validation {
        case .asset(let assetTransactionAmountError):
            handleFailureAssetAmountError(assetTransactionAmountError)
        case .algo(let algoTransactionAmountError):
            handleFailureAlgoAmountError(algoTransactionAmountError)
        case .transactionParamsMissing, .unexpected:
            handleErrorMessage(String(localized: "default-error-message"))
        }
    }

    private func handleFailureAssetAmountError(_ validation: TransactionAmountAssetError) {
        switch validation {
        case .exceededLimit:
            handleErrorMessage(String(localized: "send-asset-amount-error"))
        case .requiredMinimumBalance:
            displayRequiredMinAlgoWarning()
        }
    }

    private func handleFailureAlgoAmountError(_ validation: TransactionAmountAlgoError) {
        switch validation {
        case .exceededLimit:
            handleErrorMessage(String(localized: "send-algos-amount-error"))
        case .requiredMinimumBalance:
            displayMaxTransactionWarning()
        case .participationKey:
            presentParticipationKeyWarningForMaxTransaction()
        case .lowBalance:
            displayRequiredMinAlgoWarning()
        }
    }

    private func handleErrorMessage(_ errorMessage: String) {
        let errorTitle = String(localized: "title-error")

        bannerController?.presentErrorBanner(
            title: errorTitle,
            message: errorMessage
        )
    }
}

extension SendTransactionScreen {
    private func displayRequiredMinAlgoWarning() {
        let algoAssetItem = AssetItem(
            asset: draft.from.algo,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter,
            currencyFormattingContext: .standalone(),
            isAmountHidden: false
        )

        let draft = InsufficientAlgoBalanceDraft(algoAssetItem: algoAssetItem)

        let screen = Screen.insufficientAlgoBalance(draft: draft) {
            [unowned self] event in
            self.dismiss(animated: true)
        }

        transitionToInsufficientAlgoBalance.perform(
            screen,
            by: .presentWithoutNavigationController
        )
    }
}

extension SendTransactionScreen {
    private func displayMaxTransactionWarning() {
        guard let transactionParams = transactionParams else {
            return
        }

        let viewModel = MaximumBalanceWarningViewModel(draft.from, transactionParams)

        var bottomWarningDescription: BottomWarningViewConfigurator.BottomWarningDescription?

        if let description = viewModel.description {
            bottomWarningDescription = .plain(description)
        }

        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: String(localized: "min-balance-title"),
            description: bottomWarningDescription,
            primaryActionButtonTitle: String(localized: "title-continue"),
            secondaryActionButtonTitle: String(localized: "title-cancel"),
            primaryAction: {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.amount = self.draft.from.algo.amount.toAlgos.toNumberStringWithSeparatorForLabel ?? "0"
                self.handleSuccessAmountValidation()
            }
        )

        modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }
}

// MARK: - NumpadViewDelegate
extension SendTransactionScreen: NumpadViewDelegate {
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadButton.NumpadKey) {
        var newValue = amount

        let hasDraftFraction = draft.fractionCount > 0

        if hasDraftFraction &&
            newValue.fractionCount >= draft.fractionCount &&
            value != .delete {
            return
        }

        switch value {
        case .number(let numberValue):
            if amount == "0" {
                isAmountResetted = false
                newValue = numberValue
            } else {
                newValue.append(contentsOf: numberValue)
            }
        case .spacing:
            return
        case .delete:
            if amount.count == 1 {
                isAmountResetted = true
                newValue = "0"
            } else if amount == "0" {
                return
            } else {
                newValue.removeLast(1)
            }
        case .decimalSeparator:
            guard hasDraftFraction else {
                return
            }

            let decimalSeparator = Locale.current.decimalSeparator?.first ?? "."

            if amount.contains(decimalSeparator) {
                return
            }
            newValue.append(decimalSeparator)
        }

        amount = newValue
        numpadView.deleteButtonIsHidden = amount == "0" && isAmountResetted
        bindAmount()
    }

    private func validate(value: String) -> TransactionAmountValidation {
        guard let decimalAmount = value.decimalAmount else {
            return .failure(.unexpected)
        }

        let asset: Asset?

        switch draft.transactionMode {
        case .algo:
            asset = nil
        case .asset(let selectedAsset):
            asset = selectedAsset
        }

        return amountValidator.validate(amount: decimalAmount, on: asset)
    }

    private func presentParticipationKeyWarningForMaxTransaction() {
        let alertController = UIAlertController(
            title: String(localized: "send-algos-account-delete-title"),
            message: String(localized: "send-algos-account-delete-body"),
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: String(localized: "title-cancel"), style: .cancel)

        let proceedAction = UIAlertAction(title: String(localized: "title-proceed"), style: .destructive) { _ in
            self.displayMaxTransactionWarning()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(proceedAction)

        present(alertController, animated: true, completion: nil)
    }

    private func getTransactionParams() {
        sharedDataController.getTransactionParams { result in
            switch result {
            case .success(let params):
                self.transactionParams = params
                self.amountValidator.setTransactionParams(params)
            case .failure(let error):
                self.bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.localizedDescription)
            }
        }
    }
}

// MARK: - EditNoteScreenDelegate
extension SendTransactionScreen: EditNoteScreenDelegate {
    func editNoteScreen(
        _ screen: EditNoteScreen,
        didUpdateNote note: String?
    ) {
        screen.closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else {
                return
            }

            if self.draft.lockedNote == nil {
                self.note = note
                self.draft.note = note
            }
        }
    }
}

// MARK: - TransactionSendControllerDelegate
extension SendTransactionScreen: TransactionSendControllerDelegate {
    func transactionSendControllerDidValidate(_ controller: TransactionSendController) {
        stopLoading { [weak self] in
            guard let self = self else {
                return
            }
            self.openSendTransactionPreview(controller)
        }
    }
    
    private func openSendTransactionPreview(_ controller: TransactionSendController) {
        let controller = open(
            .sendTransactionPreview(
                draft: controller.draft
            ),
            by: .push
        ) as? SendTransactionPreviewScreen
        controller?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didCompleteTransaction:
                self.eventHandler?(.didCompleteTransaction)
            case .didEditNote(let note):
                self.didEditNote(note: note)
            default: break
            }
        }
    }

    func transactionSendController(
        _ controller: TransactionSendController,
        didFailValidation error: TransactionSendControllerError
    ) {
        stopLoading { [weak self] in
            guard let self = self else {
                return
            }

            switch error {
            case .closingSameAccount:
                self.bannerController?.presentErrorBanner(
                    title: String(localized: "title-error"),
                    message: String(localized: "send-transaction-max-same-account-error")
                )
            case .algo(let algoError):
                switch algoError {
                case .algoAddressNotSelected:
                    self.bannerController?.presentErrorBanner(
                        title: String(localized: "title-error"),
                        message: String(localized: "send-algos-address-not-selected")
                    )
                case .invalidAddressSelected:
                    self.bannerController?.presentErrorBanner(
                        title: String(localized: "title-error"),
                        message: String(localized: "send-algos-receiver-address-validation")
                    )
                case .minimumAmount:
                    let configurator = BottomWarningViewConfigurator(
                        image: "icon-info-red".uiImage,
                        title: String(localized: "send-algos-minimum-amount-error-new-account-title"),
                        description: .plain(String(localized: "send-algos-minimum-amount-error-new-account-description")),
                        secondaryActionButtonTitle: String(localized: "title-i-understand")
                    )

                    self.modalTransition.perform(
                        .bottomWarning(configurator: configurator),
                        by: .presentWithoutNavigationController
                    )
                }
            case .asset(let assetError):
                switch assetError {
                case .assetNotSupported(let address):
                    if let accountInDevice = sharedDataController.accountCollection[address],
                       accountInDevice.value.authorization.isAuthorized {
                        stopLoading { [weak self] in
                            guard let self = self else {
                                return
                            }
                            
                            if SendAssetAndOptInTransactionInfoScreenDisplayStore().hasPermissionToAskAgain {
                                self.transactionSendControllerShouldShowInfoScreen(controller)
                            } else {
                                controller.draft.isReceiverOptingInToAsset = true
                                self.openSendTransactionPreview(controller)
                            }
                        }
                        return
                    }
                    
                    self.openSendAssetInbox(address)
                case .minimumAmount:
                    self.bannerController?.presentErrorBanner(
                        title: String(localized: "title-error"),
                        message: String(localized: "send-asset-amount-error")
                    )
                }
            case .amountNotSpecified, .mismatchReceiverAddress:
                self.bannerController?.presentErrorBanner(
                    title: String(localized: "title-error"),
                    message: String(localized: "send-algos-receiver-address-validation")
                )
            case .internetConnection:
                self.bannerController?.presentErrorBanner(
                    title: String(localized: "title-error"),
                    message: String(localized: "title-internet-connection")
                )
            }
        }
    }

    private func stopLoading(execute: @escaping () -> Void) {
        loadingController?.stopLoadingAfter(
            seconds: 0.3,
            on: .main,
            execute: execute
        )
    }
    
    private func transactionSendControllerShouldShowInfoScreen(_ controller: TransactionSendController) {
        let infoController = self.open(
            .sendAssetAndOptInTransactionInfo,
            by: .present
        ) as? SendAssetAndOptInTransactionInfoScreen
        infoController?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didTapContinue:
                infoController?.dismissScreen {
                    controller.draft.isReceiverOptingInToAsset = true
                    self.openSendTransactionPreview(controller)
                }
            }
        }
    }
}

extension SendTransactionScreen {
    private func openSendAssetInbox(_ receiver: String) {
        guard let api,
              let amount = draft.amount,
              let asset = draft.asset else {
            return
        }
        
        let isTestNet = api.isTestNet
        let appID: Int64
        let appAddress: String
        if isTestNet {
            appID = AppEnvironment.current.testNetARC59AppID
            appAddress = AppEnvironment.current.testNetARC59AppAddress
        } else {
            appID = AppEnvironment.current.mainNetARC59AppID
            appAddress = AppEnvironment.current.mainNetARC59AppAddress
        }
        
        let draft = SendAssetInboxDraft(
            sender: draft.from,
            receiver: receiver,
            amount: amount,
            asset: asset,
            appAddress: appAddress,
            appID: appID
        )
        
        let screen = open(
            .sendAssetInbox(draft: draft),
            by: .present
        ) as? SendAssetInboxScreen
        
        screen?.eventHandler = {
            [weak self, weak screen] event in
            guard let self,
                  let screen else {
                return
            }
            
            switch event {
            case .send:
                screen.dismissScreen()
                self.dismissScreen()
            case .close:
                screen.dismissScreen()
            case .readMore(let urlString):
                guard let urlString,
                      let url = URL(string: urlString) else {
                    return
                }
                screen.open(url)
            }
        }
    }
}

extension SendTransactionScreen {
    enum Event {
        case didCompleteTransaction
    }
}
