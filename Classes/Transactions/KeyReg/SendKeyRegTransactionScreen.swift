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

//   SendKeyRegTransactionScreen.swift

import UIKit
import SwiftUI

final class SendKeyRegTransactionScreen:
    BaseViewController,
    TransactionControllerDelegate,
    EditNoteScreenDelegate {
    
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?
    
    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToEditNote = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private var loadingScreen: LoadingScreen?
    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?
    
    private lazy var transactionController: TransactionController = {
        return TransactionController(
            api: api!,
            sharedDataController: sharedDataController,
            bannerController: bannerController,
            analytics: analytics
        )
    }()
    
    private lazy var currencyFormatter = CurrencyFormatter()
    
    private lazy var transactionView = SendKeyRegTransactionView(transactionDraft: transactionDraft)
    
    private let account: Account
    private var transactionDraft: KeyRegTransactionSendDraft
    
    init(
        account: Account,
        transactionDraft: KeyRegTransactionSendDraft,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.transactionDraft = transactionDraft
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        add(UIHostingController(rootView: transactionView))
        title = String(localized: "title-txn-sign-request")
    }
    
    override func setListeners() {
        super.setListeners()
        transactionController.delegate = self
        
        transactionView.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .didAddNote:
                addNote()
            case .didShowRawTransaction:
                showRawTransaction()
            case .didConfirmTransaction:
                completeTransaction()
            }
        }
    }
}

private extension SendKeyRegTransactionScreen {
    func addNote() {
        let screen: Screen = .editNote(
            note: transactionDraft.note,
            isLocked: false,
            delegate: self
        )

        transitionToEditNote.perform(
            screen,
            by: .present
        )
    }
    
    func showRawTransaction() {
        var transaction: [String: Any] = [QRText.CodingKeys.type.rawValue: "keyreg"]
        
        if let fee = transactionDraft.fee {
            transaction[QRText.CodingKeys.fee.rawValue] = fee
        }

        if let selectionKey = transactionDraft.selectionKey {
            transaction[QRText.CodingKeys.selectionKey.rawValue] = selectionKey
        }
        
        if let voteKeyDilution = transactionDraft.voteKeyDilution {
            transaction[QRText.CodingKeys.voteKeyDilution.rawValue] = voteKeyDilution
        }
        
        if let stateProofKey = transactionDraft.stateProofKey {
            transaction[QRText.CodingKeys.stateProofKey.rawValue] = stateProofKey
        }
        
        if let voteKey = transactionDraft.voteKey {
            transaction[QRText.CodingKeys.votingKey.rawValue] = voteKey
        }

        if let voteFirst = transactionDraft.voteFirst {
            transaction[QRText.CodingKeys.voteFirst.rawValue] = voteFirst
        }
        
        if let voteLast = transactionDraft.voteLast {
            transaction[QRText.CodingKeys.voteLast.rawValue] = voteLast
        }
        
        if let lockedNote = transactionDraft.lockedNote {
            transaction[QRText.CodingKeys.lockedNote.rawValue] = lockedNote
        }
        
        if let note = transactionDraft.note {
            transaction[QRText.CodingKeys.note.rawValue] = note
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: transaction, options: [.prettyPrinted]) else {
            return
        }

        open(
            .jsonDisplay(
                jsonData: data,
                title: String(localized: "wallet-connect-raw-transaction-title")
            ),
            by: .present
        )
    }
    
    private func completeTransaction() {
        if !transactionController.canSignTransaction(for: account) { return }

        transactionController.setTransactionDraft(transactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .keyreg)

        if account.requiresLedgerConnection() {
            openLedgerConnection()

            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
    
    private func openLoading() {
        loadingScreen = open(
            .loading(viewModel: IncomingASAsDetailLoadingScreenViewModel()),
            by: .push
        ) as? LoadingScreen
    }
    
    private func openSuccess(
        _ transactionId: TransactionID?
    ) {
        let successResultScreenViewModel = IncomingASAsDetailSuccessResultScreenViewModel(
            title: String(localized: "title-txn-completed"),
            detail: String(localized: "incoming-asas-detail-success-detail")
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
                self.dismissScreen { [weak self] in
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

        open(url)
    }
}

extension SendKeyRegTransactionScreen {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        openLoading()
    }
    
    func transactionController(
        _ transactionController: TransactionController,
        didCompletedTransaction id: TransactionID
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self else { return }
            self.openSuccess(id)
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        loadingScreen?.popScreen()

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: error.asAFError?.errorDescription ?? error.localizedDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        loadingScreen?.popScreen()

        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: apiError.debugDescription
            )
        default:
            bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: error.debugDescription
            )
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

        loadingScreen?.popScreen()
    }

    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil
    }
}

extension SendKeyRegTransactionScreen {
    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController?.presentErrorBanner(
                title: String(localized: "asset-min-transaction-error-title"),
                message: String(format: String(localized: "send-algos-minimum-amount-custom-error"), amountText.someString)
            )
        case .invalidAddress:
            bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: String(localized: "send-algos-receiver-address-validation")
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: error.debugDescription
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

extension SendKeyRegTransactionScreen {
    func editNoteScreen(
        _ screen: EditNoteScreen,
        didUpdateNote note: String?
    ) {
        screen.closeScreen(by: .dismiss) {
            [weak self] in
            guard let self else { return }
            
            transactionDraft.note = note
            transactionView.viewModel.items[transactionView.viewModel.items.count - 1].value = note ?? ""
        }
    }
}

extension SendKeyRegTransactionScreen {
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

                self.loadingScreen?.popScreen()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension SendKeyRegTransactionScreen {
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

extension SendKeyRegTransactionScreen {
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

                self.loadingScreen?.popScreen()
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

extension SendKeyRegTransactionScreen {
    enum Event {
        case didCompleteTransaction
    }
}
