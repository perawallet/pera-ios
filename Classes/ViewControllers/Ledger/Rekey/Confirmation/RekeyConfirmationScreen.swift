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

//   RekeyConfirmationScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class RekeyConfirmationScreen:
    ScrollScreen,
    NavigationBarLargeTitleConfigurable,
    TransactionControllerDelegate {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    var navigationBarScrollView: UIScrollView {
        return scrollView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private(set) lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)
    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()

    private lazy var bodyView = ALGActiveLabel()
    private lazy var summaryView = RekeyInfoView()
    private lazy var informationContentView = MacaroonUIKit.VStackView()
    private lazy var primaryActionView = MacaroonUIKit.Button()

    private lazy var transitionToOverwriteRekeyConfirmation = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private lazy var transactionController: TransactionController = {
        return TransactionController(
            api: api!,
            sharedDataController: sharedDataController,
            bannerController: bannerController,
            analytics: analytics,
            hdWalletStorage: hdWalletStorage
        )
    }()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let theme: RekeyConfirmationScreenTheme
    private let session: Session
    private let sharedDataController: SharedDataController
    private let bannerController: BannerController
    private let loadingController: LoadingController
    private let analytics: ALGAnalytics
    private let hdWalletStorage: HDWalletStorable

    private let sourceAccount: Account
    private let authAccount: Account?
    private let newAuthAccount: Account

    init(
        sourceAccount: Account,
        authAccount: Account? = nil,
        newAuthAccount: Account,
        theme: RekeyConfirmationScreenTheme = .init(),
        api: ALGAPI,
        session: Session,
        sharedDataController: SharedDataController,
        bannerController: BannerController,
        loadingController: LoadingController,
        analytics: ALGAnalytics,
        hdWalletStorage: HDWalletStorable
    ) {
        self.sourceAccount = sourceAccount
        self.authAccount = authAccount
        self.newAuthAccount = newAuthAccount
        self.theme = theme
        self.session = session
        self.sharedDataController = sharedDataController
        self.bannerController = bannerController
        self.loadingController = loadingController
        self.analytics = analytics
        self.hdWalletStorage = hdWalletStorage
        super.init(api: api)
    }

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        navigationItem.largeTitleDisplayMode = .never
        navigationBarLargeTitleController.title = String(localized: "ledger-rekey-confirm-title")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func linkInteractors() {
        super.linkInteractors()

        navigationBarLargeTitleController.activate()

        transactionController.delegate = self
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    /// <mark>
    /// UIScrollViewDelegate
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        navigationBarLargeTitleController.scrollViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset,
            contentOffsetDeltaYBelowLargeTitle: 0
        )
    }
}

extension RekeyConfirmationScreen {
    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addBody()
        addSummary()
        addInformationContent()
        addPrimaryAction()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNavigationBarLargeTitle() {
        contentView.addSubview( navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(theme.navigationBarEdgeInset)
        }
    }

    private func addBody() {
        bodyView.customizeAppearance(theme.body)

        contentView.addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top == navigationBarLargeTitleView.snp.bottom + theme.spacingBetweenTitleAndBody
            $0.leading == theme.bodyHorizontalEdgeInsets.leading
            $0.trailing == theme.bodyHorizontalEdgeInsets.trailing
        }

        bindBody()
    }

    private func addSummary() {
        summaryView.customize(theme.summary)

        contentView.addSubview(summaryView)
        summaryView.snp.makeConstraints {
            $0.top == bodyView.snp.bottom + theme.spacingBetweenBodyAndSummary
            $0.leading == theme.summaryHorizontalEdgeInsets.leading
            $0.bottom == 0
            $0.trailing == theme.summaryHorizontalEdgeInsets.trailing
        }

        bindSummary()
    }

    private func addInformationContent() {
        footerView.addSubview(informationContentView)
        informationContentView.spacing = theme.spacingBetweenInformationItems
        informationContentView.snp.makeConstraints {
            $0.top == theme.informationContentEdgeInsets.top
            $0.leading == theme.informationContentEdgeInsets.leading
            $0.trailing == theme.informationContentEdgeInsets.trailing
        }

        let hasAuthAccount = authAccount != nil
        if hasAuthAccount {
            addCurrentlyRekeyed()
        }

        addTransactionFee()
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)
        primaryActionView.contentEdgeInsets = theme.primaryActionContentEdgeInsets

        footerView.addSubview(primaryActionView)
        primaryActionView.snp.makeConstraints {
            $0.top == informationContentView.snp.bottom + theme.primaryActionEdgeInsets.top
            $0.leading == theme.primaryActionEdgeInsets.leading
            $0.trailing == theme.primaryActionEdgeInsets.trailing
            $0.bottom == theme.primaryActionEdgeInsets.bottom
        }

        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )

        bindPrimaryAction()
    }
}

extension RekeyConfirmationScreen {
    private func addCurrentlyRekeyed() {
        guard let authAccount else { return }

        let view = SecondaryListItemView()
        let theme = RekeyConfirmationInformationItemCommonTheme()
        view.customize(theme)
        informationContentView.addArrangedSubview(view)

        let viewModel = CurrentlyRekeyedAccountInformationItemViewModel(account: authAccount)
        view.bindData(viewModel)
    }

    private func addTransactionFee() {
        let view = SecondaryListItemView()
        let theme = RekeyConfirmationInformationItemCommonTheme()
        view.customize(theme)
        informationContentView.addArrangedSubview(view)

        let fee = Transaction.Constant.minimumFee
        let viewModel = TransactionFeeSecondaryListItemViewModel(fee: fee)
        view.bindData(viewModel)
    }
}

extension RekeyConfirmationScreen {
    private func bindBody() {
        let viewModel = RekeyConfirmationBodyViewModel(authAccount: authAccount)

        guard let text = viewModel.text else {
            bodyView.text = nil
            bodyView.attributedText = nil
            return
        }

        if let highlightedText = viewModel.highlightedText {
            let hyperlink: ALGActiveType = .word(highlightedText.text)
            bodyView.attachHyperlink(
                hyperlink,
                to: text,
                attributes: highlightedText.attributes
            ) {
                [unowned self] in
                self.open(AlgorandWeb.rekey.link)
            }

            return
        }

        text.load(in: bodyView)
    }

    private func bindSummary() {
        let viewModel = RekeySummaryInfoViewModel(
            sourceAccount: sourceAccount,
            authAccount: newAuthAccount
        )
        summaryView.bindData(viewModel)
    }

    private func bindPrimaryAction() {
        primaryActionView.editTitle = .string(String(localized: "title-confirm"))
    }
}

extension RekeyConfirmationScreen {
    @objc
    private func performPrimaryAction() {
        if let authAccount {
            openOverwriteRekeyConfirmationScreen(authAccount: authAccount)
            return
        }

        performRekeying()
    }

    private func openOverwriteRekeyConfirmationScreen(authAccount: Account) {
        let eventHandler: OverwriteRekeyConfirmationSheet.EventHandler = {
            [weak self] event in
            guard let self else { return }
            switch event {
            case .didConfirm:
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    performRekeying()
                }
            case .didCancel:
                self.dismiss(animated: true)
            case .didTapLearnMore:
                let visibleScreen = findVisibleScreen()
                visibleScreen.open(AlgorandWeb.rekey.link)
            }
        }
        transitionToOverwriteRekeyConfirmation.perform(
            .overwriteRekeyConfirmation(
                sourceAccount: sourceAccount,
                authAccount: authAccount,
                eventHandler: eventHandler
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension RekeyConfirmationScreen {
    private func performRekeying() {
        if !transactionController.canSignTransaction(for: sourceAccount) { return }

        loadingController.startLoadingWithMessage(String(localized: "title-loading"))

        let rekeyTransactionDraft = RekeyTransactionSendDraft(
            account: sourceAccount,
            rekeyedTo: newAuthAccount.address
        )

        transactionController.setTransactionDraft(rekeyTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .rekey)

        if sourceAccount.requiresLedgerConnection() {
            openLedgerConnection()

            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension RekeyConfirmationScreen {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController.stopLoading()

        analytics.track(.rekeyAccount())
        saveRekeyedAccountDetails()

        eventHandler?(.didRekey)
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        loadingController.stopLoading()

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            bannerController.presentErrorBanner(
                title: String(localized: "title-error"),
                message: error.asAFError?.errorDescription ?? error.localizedDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        loadingController.stopLoading()

        switch error {
        case let .network(apiError):
            bannerController.presentErrorBanner(title: String(localized: "title-error"), message: apiError.debugDescription)
        default:
            bannerController.presentErrorBanner(title: String(localized: "title-error"), message: error.debugDescription)
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        ledgerConnectionScreen?.dismiss(animated: true) {
            self.ledgerConnectionScreen = nil

            self.openSignWithLedgerProcess(
                transactionController: transactionController,
                ledgerDeviceName: ledger
            )
        }
    }

    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil

        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        loadingController.stopLoading()
    }

    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil
    }
}

extension RekeyConfirmationScreen {
    private func saveRekeyedAccountDetails() {
        guard let localAccount = session.accountInformation(from: sourceAccount.address),
              let ledgerDetail = newAuthAccount.ledgerDetail else {
            return
        }

        let isRekeyed = !sourceAccount.isSameAccount(with: newAuthAccount.address)
        if isRekeyed {
            localAccount.addRekeyDetail(
                ledgerDetail,
                for: newAuthAccount.address
            )
        }

        saveAccount(localAccount)
    }

    private func saveAccount(_ localAccount: AccountInformation) {
        session.authenticatedUser?.updateAccount(localAccount)
    }
}

extension RekeyConfirmationScreen {
    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController.presentErrorBanner(
                title: String(localized: "asset-min-transaction-error-title"),
                message: String(format: String(localized: "send-algos-minimum-amount-custom-error"), amountText.someString)
            )
        case .invalidAddress:
            bannerController.presentErrorBanner(
                title: String(localized: "title-error"),
                message: String(localized: "send-algos-receiver-address-validation")
            )
        case let .sdkError(error):
            bannerController.presentErrorBanner(
                title: String(localized: "title-error"), message: error.debugDescription
            )
        case .ledgerConnection:
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.ledgerConnectionScreen = nil

                self.openLedgerConnectionIssues()
            }
        default:
            break
        }
    }
}

extension RekeyConfirmationScreen {
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

                self.loadingController.stopLoading()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension RekeyConfirmationScreen {
    private func openLedgerConnectionIssues() {
        transitionToLedgerConnectionIssuesWarning.perform(
            .bottomWarning(
                configurator: BottomWarningViewConfigurator(
                    image: "icon-info-green".uiImage,
                    title: String(localized: "ledger-pairing-issue-error-title"),
                    description: .plain(String(localized: "ble-error-fail-ble-connection-repairing")),
                    secondaryActionButtonTitle: String(localized: "title-ok")
                )
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension RekeyConfirmationScreen {
    private func openSignWithLedgerProcess(
        transactionController: TransactionController,
        ledgerDeviceName: String
    ) {
        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledgerDeviceName,
            totalTransactionCount: 1
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

                self.loadingController.stopLoading()
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

extension RekeyConfirmationScreen {
    func transactionController(
        _ transactionController: TransactionController,
        didCompletedTransaction id: TransactionID
    ) {}

    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) {}

    func transactionControllerDidRejectedLedgerOperation(_ transactionController: TransactionController) {}
}

extension RekeyConfirmationScreen {
    enum Event {
        case didRekey
    }
}
