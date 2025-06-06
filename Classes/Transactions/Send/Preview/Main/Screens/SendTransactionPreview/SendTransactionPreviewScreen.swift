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
//   SendTransactionPreviewScreen.swift

import Foundation
import UIKit
import MacaroonUIKit

final class SendTransactionPreviewScreen: BaseScrollViewController {
   typealias EventHandler = (Event) -> Void

   override var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
      return .automatic
   }
   override var contentSizeBehaviour: BaseScrollViewController.ContentSizeBehaviour {
      return .intrinsic
   }

   var eventHandler: EventHandler?
   
   private lazy var transitionToEditNote = BottomSheetTransition(presentingViewController: self)
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
   private var loadingScreen: LoadingScreen?

   private lazy var transactionDetailView = SendTransactionPreviewView()
   private lazy var nextButton = Button()
   private lazy var theme = Theme()

   private lazy var currencyFormatter = CurrencyFormatter()

   private var draft: TransactionSendDraft
   private lazy var transactionController = {
      guard let api = api else {
         fatalError("API should be set.")
      }
      return TransactionController(
         api: api,
         sharedDataController: sharedDataController,
         bannerController: bannerController,
         analytics: analytics,
         hdWalletStorage: hdWalletStorage
      )
   }()

   private var isLayoutFinalized = false

   init(
      draft: TransactionSendDraft,
      configuration: ViewControllerConfiguration
   ) {
      self.draft = draft
      super.init(configuration: configuration)
   }
   
   override func didTapDismissBarButton() -> Bool {
      eventHandler?(.didPerformDismiss)
      return true
   }

   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      if !isLayoutFinalized {
         isLayoutFinalized = true
      }
   }

   override func configureAppearance() {
      super.configureAppearance()
      view.customizeBaseAppearance(backgroundColor: theme.background)
      title = String(localized: "send-transaction-preview-title")
   }

   override func prepareLayout() {
      super.prepareLayout()
      addNextButton()
      addTransactionDetailView()
   }

   override func bindData() {
      super.bindData()

      let currency = sharedDataController.currency

      transactionDetailView.bindData(
         SendTransactionPreviewViewModel(
            draft,
            currency: currency,
            currencyFormatter: currencyFormatter
         ),
         currency: currency,
         currencyFormatter: currencyFormatter
      )
   }

   override func linkInteractors() {
      super.linkInteractors()

      transactionController.delegate = self
      nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
   }

   override func viewDidLoad() {
      super.viewDidLoad()

      fetchTransactionParams()
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

   private func fetchTransactionParams() {
      loadingController?.startLoadingWithMessage(String(localized: "title-loading"))

      sharedDataController.getTransactionParams(isCacheEnabled: true) { [weak self] paramsResult in
         guard let self else {
            return
         }

         self.loadingController?.stopLoading()

         switch paramsResult {
         case .success(let params):
            self.bindTransaction(with: params)
         case .failure(let error):
            self.bannerController?.presentErrorBanner(
               title: String(localized: "title-error"),
               message: error.localizedDescription
            )
         }
      }
   }

   /// <todo>: Add Unit Test for composing transaction and view model changes
   private func bindTransaction(with params: TransactionParams) {
      var transactionDraft = composeTransaction()
      let builder: TransactionDataBuildable
      
      var isOptInAndSendTransaction = false

      if transactionDraft is AlgosTransactionSendDraft {
         builder = AlgoTransactionDataBuilder(params: params, draft: transactionDraft, initialSize: nil)
      } else if let draft = transactionDraft as? AssetTransactionSendDraft {
         if draft.isReceiverOptingInToAsset {
            isOptInAndSendTransaction = true
            builder = OptInAndSendTransactionDataBuilder(
               sharedDataController: sharedDataController,
               params: params,
               draft: transactionDraft
            )
         } else {
            builder = AssetTransactionDataBuilder(
               params: params,
               draft: transactionDraft
            )
         }
      } else {
         return
      }

      let dataArray = builder.composeData()?.map { $0.transaction }
      guard let dataArray,
            let firstTransactionData = dataArray.first else {
         return
      }
      
      var totalFee: UInt64 = 0
      
      let receiver = draft.toAccount?.address ??
         draft.toContact?.address ??
         draft.toNameService?.address
      
      if let receiver,
         let receiverAccount = sharedDataController.accountCollection[receiver]?.value,
         isOptInAndSendTransaction {

         let receiverMinBalanceFee = calculateExtraAlgoAmount(
            receiverAlgoAmount: receiverAccount.algo.amount,
            receiverMinBalanceAmount: receiverAccount.calculateMinBalance()
         )
         
         totalFee = UInt64(receiverMinBalanceFee)
      }
      
      for data in dataArray {
         var error: NSError?
         let json = AlgorandSDK().msgpackToJSON(
            data,
            error: &error
         )

         guard let jsonData = json.data(using: .utf8) else { return }
         
         do {
            let transactionDetail = try JSONDecoder().decode(
               SDKTransaction.self,
               from: jsonData
            )
            
            totalFee += transactionDetail.fee ?? 0
         } catch {
            bannerController?.presentErrorBanner(
               title: String(localized: "title-error"),
               message: error.localizedDescription
            )
         }
      }

      transactionDraft.fee = totalFee

      do {
         var error: NSError?
         let json = AlgorandSDK().msgpackToJSON(
            firstTransactionData,
            error: &error
         )

         guard let jsonData = json.data(using: .utf8) else { return }
         
         let transactionDetail = try JSONDecoder().decode(
            SDKTransaction.self,
            from: jsonData
         )

         /// <note>: When transaction detail fetched from SDK, amount will be updated as well
         /// Otherwise, amount field wouldn't be normalized with minimum balance
         /// This is only needed for Algo transaction
         if transactionDraft is AlgosTransactionSendDraft {
            transactionDraft.amount = transactionDetail.amount.toAlgos
         }

         let currency = sharedDataController.currency

         transactionDetailView.bindData(
            SendTransactionPreviewViewModel(
               transactionDraft,
               currency: currency,
               currencyFormatter: self.currencyFormatter
            ),
            currency: currency,
            currencyFormatter: self.currencyFormatter
         )
      } catch {
         self.bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.localizedDescription)
      }
   }

   private func composeTransaction() -> TransactionSendDraft {
      guard let sendTransactionDraft = draft as? SendTransactionDraft else {
         return draft
      }

      var transactionDraft: TransactionSendDraft

      switch sendTransactionDraft.transactionMode {
      case .algo:
         transactionDraft = AlgosTransactionSendDraft(
            from: draft.from,
            toAccount: draft.toAccount,
            amount: draft.amount,
            fee: nil,
            isMaxTransaction: draft.isMaxTransaction,
            identifier: nil,
            note: draft.note,
            lockedNote: draft.lockedNote
         )
         transactionDraft.toContact = draft.toContact
         transactionDraft.toNameService = draft.toNameService

      case .asset(let asset):
         var assetTransactionDraft = AssetTransactionSendDraft(
            from: draft.from,
            toAccount: draft.toAccount,
            amount: draft.amount,
            assetIndex: asset.id,
            assetDecimalFraction: asset.decimals,
            isVerifiedAsset: asset.verificationTier.isVerified,
            note: draft.note,
            lockedNote: draft.lockedNote,
            isReceiverOptingInToAsset: sendTransactionDraft.isReceiverOptingInToAsset
         )
         assetTransactionDraft.toContact = draft.toContact
         assetTransactionDraft.asset = asset
         assetTransactionDraft.toNameService = draft.toNameService

         if sendTransactionDraft.isOptingOut {
            let closeTo =
               draft.toAccount?.address ??
               draft.toContact?.address ??
               draft.toNameService?.address
            if let closeTo {
               assetTransactionDraft.assetCreator = closeTo
            }
         }

         transactionDraft = assetTransactionDraft
      }

      return transactionDraft
   }

   private func composedTransactionType(draft: TransactionSendDraft) -> TransactionController.TransactionType {
      if draft is AlgosTransactionSendDraft {
         return .algo
      } else if let assetTransactionDraft = draft as? AssetTransactionSendDraft {
         if assetTransactionDraft.isReceiverOptingInToAsset {
            return .optInAndSend
         } else {
            return .asset
         }
      }

      return .algo
   }
}

extension SendTransactionPreviewScreen {
   @objc
   private func didTapNext() {
      if !transactionController.canSignTransaction(for: draft.from) {
         assertionFailure("Can't sign transaction")
         return
      }
      
      let composedTransacation = composeTransaction()
      let transactionType = composedTransactionType(draft: composedTransacation)

      if let sendTransactionDraft = draft as? SendTransactionDraft,
         sendTransactionDraft.isOptingOut,
         let asset = sendTransactionDraft.asset {
         let monitor = sharedDataController.blockchainUpdatesMonitor
         let request = OptOutBlockchainRequest(account: draft.from, asset: asset)
         monitor.startMonitoringOptOutUpdates(request)
      }

      transactionController.delegate = self
      transactionController.setTransactionDraft(composedTransacation)
      transactionController.getTransactionParamsAndComposeTransactionData(for: transactionType)

      if draft.from.requiresLedgerConnection() {
         openLedgerConnection()

         transactionController.initializeLedgerTransactionAccount()
         transactionController.startTimer()
         return
      }
      
      if transactionType == .optInAndSend {
         guard let receiver = draft.toAccount?.address ??
                  draft.toContact?.address ??
                  draft.toNameService?.address,
               let receiverAccount = sharedDataController.accountCollection[receiver]?.value,
               receiverAccount.authorization.isAuthorized else {
            assertionFailure("Not authorized to send transaction")
            return
         }

         if receiverAccount.requiresLedgerConnection() {
            openLedgerConnection()
         }
      }
   }
}

extension SendTransactionPreviewScreen {
   private func addTransactionDetailView() {
      contentView.addSubview(transactionDetailView)
      transactionDetailView.snp.makeConstraints {
         $0.top == 0
         $0.leading == 0
         $0.bottom == theme.contentBottomEdgeInset
         $0.trailing == 0
      }
      
      transactionDetailView.startObserving(event: .performEditNote) {
         [weak self] in
         guard let self = self else {
            return
         }
         
         let isLocked = self.draft.lockedNote != nil
         let editNote = self.draft.lockedNote ?? self.draft.note

         let screen: Screen = .editNote(
             note: editNote,
             isLocked: isLocked,
             delegate: self
         )

         self.transitionToEditNote.perform(
             screen,
             by: .present
         )
      }
   }

   private func addNextButton() {
      nextButton.customize(theme.nextButtonStyle)
      nextButton.bindData(ButtonCommonViewModel(title: String(localized: "send-transaction-preview-button")))

      footerView.addSubview(nextButton)
      nextButton.snp.makeConstraints {
         $0.top == theme.nextButtonContentEdgeInsets.top
         $0.leading == theme.nextButtonContentEdgeInsets.leading
         $0.bottom == theme.nextButtonContentEdgeInsets.bottom
         $0.trailing == theme.nextButtonContentEdgeInsets.trailing
      }
   }
}

extension SendTransactionPreviewScreen: EditNoteScreenDelegate {
   func editNoteScreen(
      _ screen: EditNoteScreen,
      didUpdateNote note: String?
   ) {
      screen.closeScreen(by: .dismiss) {
          [weak self] in
          guard let self = self else {
              return
          }

         self.draft.updateNote(note)

         self.sharedDataController.getTransactionParams(isCacheEnabled: true) {
            [weak self] paramsResult in
            guard let self else {
               return
            }

            switch paramsResult {
            case .success(let params):
               self.bindTransaction(with: params)
            case .failure(let error):
               self.bannerController?.presentErrorBanner(
                  title: String(localized: "title-error"),
                  message: error.localizedDescription
               )
            }
         }

         self.eventHandler?(.didEditNote(note: note))
      }
   }
}

extension SendTransactionPreviewScreen: TransactionControllerDelegate {
   func transactionController(
      _ transactionController: TransactionController,
      didFailedComposing error: HIPTransactionError
   ) {
      loadingScreen?.popScreen()
      switch error {
      case .network:
         displaySimpleAlertWith(title: String(localized: "title-error"), message: String(localized: "title-internet-connection"))
      case let .inapp(transactionError):
         displayTransactionError(from: transactionError)
      }

      cancelMonitoringOptOutUpdatesIfNeeded(for: transactionController)
   }

   func transactionController(
      _ transactionController: TransactionController,
      didComposedTransactionDataFor draft: TransactionSendDraft?
   ) {
      if let draft = draft as? SendTransactionDraft,
         draft.isOptingOut,
         draft.asset is CollectibleAsset {
         NotificationCenter.default.post(
            name: CollectibleListLocalDataController.didRemoveCollectible,
            object: self
         )
      }
      
      openLoading()
      transactionController.uploadTransaction()
   }

   func transactionController(
      _ transactionController: TransactionController,
      didCompletedTransaction id: TransactionID
   ) {
      asyncMain(afterDuration: 3.0) {
         [weak self] in
         guard let self = self else { return }
         
         self.openSuccess(id.identifier)
         if draft is AlgosTransactionSendDraft ||
               draft is AssetTransactionSendDraft ||
               draft is AssetTransactionARC59SendDraft {
            analytics.track(
               .completeStandardTransaction(draft: draft, transactionId: id)
            )
         }
      }
   }

   func transactionController(
      _ transactionController: TransactionController,
      didFailedTransaction error: HIPTransactionError
   ) {
      loadingScreen?.popScreen()
      switch error {
      case let .network(apiError):
         switch apiError {
         case .connection:
            displaySimpleAlertWith(title: String(localized: "title-error"), message: String(localized: "title-internet-connection"))
         default:
            bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: apiError.debugDescription)
         }
      default:
         bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.localizedDescription)
      }

      cancelMonitoringOptOutUpdatesIfNeeded(for: transactionController)
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

      loadingController?.stopLoading()

      cancelMonitoringOptOutUpdatesIfNeeded(for: transactionController)
   }
}

extension SendTransactionPreviewScreen {
   private func openLoading() {
      loadingScreen = open(
          .loading(viewModel: IncomingASAsDetailLoadingScreenViewModel()),
          by: .push
      ) as? LoadingScreen
   }

   private func openSuccess(
      _ transactionId: String?
   ) {
      let successResultScreenViewModel = IncomingASAsDetailSuccessResultScreenViewModel(
         title: String(localized: "send-transaction-preview-success-title"),
         detail: String(localized: "send-transaction-preview-success-detail")
      )
      let successScreen = loadingScreen?.open(
         .successResultScreen(viewModel: successResultScreenViewModel),
         by: .push,
         animated: false
      ) as? SuccessResultScreen
      
      successScreen?.eventHandler = {
         [weak self, weak successScreen] event in
         guard let self = self else { return }
         switch event {
         case .didTapViewDetailAction:
            self.openPeraExplorerForTransaction(transactionId)
         case .didTapDoneAction:
            successScreen?.dismissScreen { [weak self] in
                guard let self else { return }
               self.eventHandler?(.didCompleteTransaction)
            }
         }
      }
   }

    private func openPeraExplorerForTransaction(
        _ transactionID: String?
    ) {
        guard let identifierlet = transactionID,
              let url = AlgoExplorerType.peraExplorer.transactionURL(
                with: identifierlet,
                in: api?.network ?? .mainnet
              ) else {
            return
        }
        open(url)
    }
}

extension SendTransactionPreviewScreen {
   private func cancelMonitoringOptOutUpdatesIfNeeded(for transactionController: TransactionController) {
      if let sendTransactionDraft = draft as? SendTransactionDraft,
         sendTransactionDraft.isOptingOut,
         let assetID = getAssetID(from: transactionController) {
         let monitor = sharedDataController.blockchainUpdatesMonitor
         let account = draft.from
         monitor.cancelMonitoringOptOutUpdates(
            forAssetID: assetID,
            for: account
         )
      }
   }

   private func getAssetID(
       from transactionController: TransactionController
   ) -> AssetID? {
       return transactionController.assetTransactionDraft?.assetIndex
   }
}

extension SendTransactionPreviewScreen {
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
         displaySimpleAlertWith(
            title: String(localized: "title-error"),
            message: String(localized: "title-internet-connection")
         )
      }
   }
}

extension SendTransactionPreviewScreen {
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
               self.cancelMonitoringOptOutUpdatesIfNeeded(for: transactionController)
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension SendTransactionPreviewScreen {
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

extension SendTransactionPreviewScreen {
    private func openSignWithLedgerProcess(
        transactionController: TransactionController,
        ledgerDeviceName: String
    ) {
        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledgerDeviceName,
            totalTransactionCount: transactionController.ledgerTansactionCount
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
               self.cancelMonitoringOptOutUpdatesIfNeeded(for: transactionController)
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

private extension SendTransactionPreviewScreen {
   func calculateExtraAlgoAmount(
      receiverAlgoAmount: UInt64,
      receiverMinBalanceAmount: UInt64
   ) -> Int64 {
      let ASSET_OPT_IN_MBR: UInt64 = 100_000
      let ACCOUNT_MBR: UInt64 = 100_000
      
      if receiverAlgoAmount == 0 {
         return Int64(ACCOUNT_MBR + ASSET_OPT_IN_MBR)
      }

      let availableAmount = Int64(receiverAlgoAmount) - Int64(receiverMinBalanceAmount)
      let extraAlgoAmount = Int64(ASSET_OPT_IN_MBR) - availableAmount
      
      if ASSET_OPT_IN_MBR > availableAmount {
         return extraAlgoAmount
      }

      return 0
   }
}

extension SendTransactionPreviewScreen {
   enum Event {
      case didCompleteTransaction
      case didPerformDismiss
      case didEditNote(note: String?)
   }
}
