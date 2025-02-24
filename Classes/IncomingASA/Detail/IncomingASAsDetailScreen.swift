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

//   IncomingAsasDetailScreen.swift

import Foundation
import MacaroonForm
import MacaroonUIKit
import MacaroonUtils
import UIKit
import WalletConnectSwift

final class IncomingASAsDetailScreen: BaseScrollViewController {
    typealias EventHandler = (IncomingASADetailScreenEvent) -> Void
    var eventHandler: EventHandler?
    
    private lazy var theme = Theme()
    private lazy var incomingAsasDetailView = IncomingASAsDetailView()
    let draft: IncomingASAListItem?
    private let transactionController: IncomingASATransactionController
    private let copyToClipboardController: CopyToClipboardController
    
    private lazy var footerEffectView = EffectView()
    private lazy var actionsContextView = MacaroonUIKit.HStackView()
    private lazy var primaryActionView = MacaroonUIKit.Button()
    private lazy var secondaryActionView = MacaroonUIKit.Button()
    
    private lazy var transitionToRejectConfirmInfo = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var currencyFormatter = CurrencyFormatter()
    
    private unowned let presentingScreen: UIViewController

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private var account: Account?
    private var loadingScreen: LoadingScreen?
    private var visibleScreen: UIViewController {
        return presentingScreen.findVisibleScreen()
    }
    
    init(
        draft: IncomingASAListItem?,
        configuration: ViewControllerConfiguration,
        transactionController: IncomingASATransactionController,
        copyToClipboardController: CopyToClipboardController,
        presentingScreen: UIViewController
    ) {
        self.draft = draft
        self.transactionController = transactionController
        self.copyToClipboardController = copyToClipboardController
        self.presentingScreen = presentingScreen
        super.init(configuration: configuration)
    }

    
    override func configureAppearance() {
        super.configureNavigationBarAppearance()
        contentView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        bindNavigationItemTitle()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addIncomingAsasDetailView()
        addActions()
    }
    
    private func bindNavigationItemTitle() {
        title = "incoming-asa-account-inbox-header-main-title".localized
    }
    
    override func linkInteractors() {
        super.linkInteractors()

        incomingAsasDetailView.startObserving(event: .performClose) {
            [weak self] in
            self?.dismissScreen()
        }
        
        incomingAsasDetailView.startObserving(event: .performCopy) {
            [weak self] in
            if let asset = self?.draft?.asset {
                self?.copyToClipboardController.copyID(asset)
            }
        }
        transactionController.delegate = self
    }
}

extension IncomingASAsDetailScreen {
    private func addIncomingAsasDetailView() {
        contentView.addSubview(incomingAsasDetailView)
        incomingAsasDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let currency = self.sharedDataController.currency
        let currencyFormatter = self.currencyFormatter

        self.sharedDataController.sortedAccounts().forEach { accountHandle in
            
            guard let incomingASAListItem = draft,
                    accountHandle.value.address == incomingASAListItem.accountAddress else {return}
            self.account = accountHandle.value
            
            let item = AccountPortfolioItem(
                accountValue: accountHandle,
                currency: currency,
                currencyFormatter: currencyFormatter,
                isAmountHidden: false
            )
            
            incomingAsasDetailView.bindData(
                IncomingASAsDetailViewModel(
                    draft: incomingASAListItem,
                    account: accountHandle.value,
                    accountPortfolio: item,
                    currency: sharedDataController.currency,
                    currencyFormatter: CurrencyFormatter(),
                    algoGainOnClaim: incomingASAListItem.algoGainOnClaim,
                    algoGainOnReject: incomingASAListItem.algoGainOnReject
                )
            )
        }
    }
}

extension IncomingASAsDetailScreen {
    private func addActions() {
        addFooterGradient()
        addActionsContext()
    }

    private func addFooterGradient() {
        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]
        footerEffectView.effect = LinearGradientEffect(gradient: backgroundGradient)

        view.addSubview(footerEffectView)
        footerEffectView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addActionsContext() {
        footerEffectView.addSubview(actionsContextView)

        actionsContextView.spacing = theme.spacingBetweenActions

        actionsContextView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.actionMargins.bottom

            $0.top == theme.spacingBetweenListAndPrimaryAction
            $0.leading == theme.actionMargins.leading
            $0.trailing == theme.actionMargins.trailing
            $0.bottom == bottom
        }

        addSecondaryAction()
        addPrimaryAction()
    }

    private func addSecondaryAction() {
        secondaryActionView.customizeAppearance(theme.secondaryAction)

        footerEffectView.addSubview(secondaryActionView)
        secondaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)

        actionsContextView.addArrangedSubview(secondaryActionView)

        secondaryActionView.addTouch(
            target: self,
            action: #selector(performSecondaryAction)
        )
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)

        primaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        actionsContextView.addArrangedSubview(primaryActionView)

        primaryActionView.snp.makeConstraints {
            $0.width == secondaryActionView * theme.secondaryActionWidthMultiplier
        }
        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )
    }
}

extension IncomingASAsDetailScreen {
    @objc
    private func performPrimaryAction() {
        guard let draft,
              let account else {
            return
        }
        
        if account.requiresLedgerConnection() {
            openLedgerConnection()
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
        
        if draft.hasInsufficientAlgoForClaiming {
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "required-min-balance-title".localized
            )
           return
        }
        
        transactionController.getTransactionParamsAndCompleteTransaction(
            with: draft,
            for: account,
            type: .claim
        )
    }

    @objc
    private func performSecondaryAction() {
        let uiSheet = UISheet(
            image: img("icon-incoming-asa-error"),
            title: "incoming-asa-detail-screen-info-title"
                .localized
                .bodyLargeMedium(alignment: .center),
            body: UISheetBodyTextProvider(text: "incoming-asa-detail-screen-description_reject"
                .localized(params: draft?.algoGainOnReject?.toAlgos.stringValue ?? "")
                .bodyRegular(alignment: .center))
        )

        let rejectAction = UISheetAction(
            title: "incoming-asa-detail-screen-left-button-title".localized,
            style: .default
        ) { [unowned self] in
            self.dismiss(animated: true) {
                self.openLoading()
            }

            guard let draft,
                  let account else {
                return
            }
            
            if draft.hasInsufficientAlgoForRejecting {
                bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "required-min-balance-title".localized
                )
               return
            }
            
            transactionController.getTransactionParamsAndCompleteTransaction(
                with: draft,
                for: account,
                type: .reject
            )
        }
        
        let cancelAction = UISheetAction(
            title: "title-cancel".localized,
            style: .cancel
        ) { [unowned self] in
            self.dismiss(animated: true)
        }
        
        uiSheet.addAction(rejectAction)
        uiSheet.addAction(cancelAction)

        transitionToRejectConfirmInfo.perform(
            .sheetAction(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme()
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension IncomingASAsDetailScreen {
    private func openLedgerConnection() {
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.transactionController.stopBLEScan()
                self.transactionController.stopTimer()

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.loadingController?.stopLoading()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
    
    private func openSignWithLedgerProcess(ledgerDeviceName: String) {
        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledgerDeviceName,
            totalTransactionCount: transactionController.transactionCount
        )
        let eventHandler: SignWithLedgerProcessScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .performCancelApproval:
                transactionController.stopBLEScan()
                transactionController.stopTimer()

                self.signWithLedgerProcessScreen?.dismissScreen()
                self.signWithLedgerProcessScreen = nil

                self.loadingController?.stopLoading()
            }
        }
        signWithLedgerProcessScreen = transitionToSignWithLedgerProcess.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen
    }
}

extension IncomingASAsDetailScreen: IncomingASATransactionControllerDelegate {
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didCompletedTransaction transactionId: TransactionID?
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self else { return }
            self.openSuccess(transactionId)
        }
    }
    
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didSignTransactionAt index: Int
    ) {
        if let account,
           let signWithLedgerProcessScreen,
           account.requiresLedgerConnection() {
            if !signWithLedgerProcessScreen.isProgressFinished {
                signWithLedgerProcessScreen.increaseProgress()
            }
        }
    }
    
    func incomingASATransactionControllerDidStartUploadingTransaction(
        _ incomingASATransactionController: IncomingASATransactionController
    ) {
        if let account,
           account.requiresLedgerConnection() {
            signWithLedgerProcessScreen?.dismissScreen { [weak self] in
                guard let self else { return }
                self.openLoading()
            }

            signWithLedgerProcessScreen = nil
            return
        }
        
        if let account,
           !account.requiresLedgerConnection() {
            openLoading()
        }
    }
    
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        loadingScreen?.popScreen()
        
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        case let .network(apiError):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.prettyDescription
            )
        }

    }
    
    func incomingASATransactionControllerDidResetLedgerOperation(
        _ incomingASATransactionController: IncomingASATransactionController
    ) {
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil

        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        loadingController?.stopLoading()
    }
    
    func incomingASATransactionControllerDidRejectedLedgerOperation(
        _ incomingASATransactionController: IncomingASATransactionController
    ) {}
    
    func incomingASATransactionControllerDidResetLedgerOperationOnSuccess(
        _ incomingASATransactionController: IncomingASATransactionController
    ) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        loadingController?.stopLoading()
    }
    
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        ledgerConnectionScreen?.dismiss(animated: true) {
            self.ledgerConnectionScreen = nil

            self.openSignWithLedgerProcess(
                ledgerDeviceName: ledger
            )
        }
    }
    
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {}
    
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        loadingScreen?.popScreen()
        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.prettyDescription
            )
        default:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        }
    }
}

extension IncomingASAsDetailScreen {
    private func displayTransactionError(
        from transactionError: TransactionError
    ) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(
                    params: amountText.someString
                )
            )
        case .invalidAddress:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.openLedgerConnectionIssues()
            }
        default:
            break
        }
    }
    
    private func openLedgerConnectionIssues() {
        transitionToLedgerConnectionIssuesWarning.perform(
            .bottomWarning(
                configurator: BottomWarningViewConfigurator(
                    image: "icon-info-green".uiImage,
                    title: "ledger-pairing-issue-error-title".localized,
                    description: .plain("ble-error-fail-ble-connection-repairing".localized),
                    secondaryActionButtonTitle: "title-ok".localized
                )
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension IncomingASAsDetailScreen {
    private func openLoading() {
        loadingScreen = visibleScreen.open(
            .loading(viewModel: IncomingASAsDetailLoadingScreenViewModel()),
            by: .push
        ) as? LoadingScreen
    }

    private func openSuccess(
        _ transactionId: TransactionID?
    ) {
        let successResultScreenViewModel = IncomingASAsDetailSuccessResultScreenViewModel(
            title: "incoming-asas-detail-success-title"
                .localized,
            detail: "incoming-asas-detail-success-detail"
                .localized
        )
        let successScreen = loadingScreen?.open(
            .successResultScreen(viewModel: successResultScreenViewModel),
            by: .push,
            animated: false
        ) as? SuccessResultScreen

        successScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didTapViewDetailAction:
                self.openPeraExplorerForTransaction(transactionId)
            case .didTapDoneAction:
                self.visibleScreen.dismissScreen { [weak self] in
                    guard let self else { return }
                    self.eventHandler?(.didCompleteTransaction)
                }
            }
        }
    }

    private func openPeraExplorerForTransaction(
        _ transactionID: TransactionID?
    ) {
        guard let identifierlet = transactionID?.identifier,
              let url = AlgoExplorerType.peraExplorer.transactionURL(
                with: identifierlet,
                in: api?.network ?? .mainnet
              ) else {
            return
        }

        visibleScreen.open(url)
    }
}
enum IncomingASADetailScreenEvent {
    case didCompleteTransaction
}
