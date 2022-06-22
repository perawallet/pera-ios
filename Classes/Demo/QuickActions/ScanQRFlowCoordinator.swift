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

//   ScanQRFlowCoordinator.swift

import Foundation
import UIKit

/// <todo>
/// This should be removed after the routing refactor.
final class ScanQRFlowCoordinator:
    QRScannerViewControllerDelegate,
    SelectAccountViewControllerDelegate,
    AssetActionConfirmationViewControllerDelegate,
    TransactionControllerDelegate {
    private var lastTransactionDraft: SendTransactionDraft?
    private var assetConfirmationTransition: BottomSheetTransition?

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    private unowned let presentingScreen: UIViewController
    private let sharedDataController: SharedDataController
    private var api: ALGAPI
    private let bannerController: BannerController

    init(
        sharedDataController: SharedDataController,
        presentingScreen: UIViewController,
        api: ALGAPI,
        bannerController: BannerController
    ) {
        self.sharedDataController = sharedDataController
        self.presentingScreen = presentingScreen
        self.api = api
        self.bannerController = bannerController
    }
}

extension ScanQRFlowCoordinator {
    func launch() {
        let screen: Screen = .qrScanner(canReadWCSession: true)
        let qrScannerViewController = presentingScreen.open(
            screen,
            by: .present
        ) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
}

/// <mark>
/// QRScannerViewControllerDelegate
extension ScanQRFlowCoordinator {
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrText: QRText,
        completionHandler: EmptyHandler?
    ) {
        switch qrText.mode {
        case .address:
            qrScanner(
                controller,
                accountAddressWasDetected: qrText
            )
        case .algosRequest:
            qrScanner(
                controller,
                algosTransactionWasDetected: qrText
            )
        case .assetRequest:
            qrScanner(
                controller,
                assetTransactionWasDetected: qrText
            )
        case .mnemonic:
            qrScanner(
                controller,
                accountMnemonicWasDetected: qrText
            )
        case .optInRequest:
            qrScanner(
                controller,
                assetOptInWasDetected: qrText
            )
        }
    }

    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    ) {
        let visibleScreen = presentingScreen.findVisibleScreen()
        visibleScreen.displaySimpleAlertWith(
            title: "title-error".localized,
            message: "qr-scan-should-scan-valid-qr".localized
        ) { _ in
            if let handler = completionHandler {
                handler()
            }
        }
    }
}

/// <mark>
/// SelectAccountViewControllerDelegate
extension ScanQRFlowCoordinator {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for transactionAction: TransactionAction
    ) {
        switch transactionAction {
        case .optIn(let asset):
            requestOptingInToAsset(
                asset,
                to: account
            )
        default:
            sendTransaction(
                from: selectAccountViewController,
                for: account
            )
        }

    }

    private func requestOptingInToAsset(
        _ asset: AssetID,
        to account: Account
    ) {
        if account.containsAsset(asset) {
            bannerController.presentInfoBanner("asset-you-already-own-message".localized)
            return
        }

        let assetAlertDraft = AssetAlertDraft(
            account: account,
            assetId: asset,
            asset: nil,
            transactionFee: Transaction.Constant.minimumFee,
            title: "asset-add-confirmation-title".localized,
            detail: "asset-add-warning".localized,
            actionTitle: "title-approve".localized,
            cancelTitle: "title-cancel".localized
        )

        let visibleScreen = presentingScreen.findVisibleScreen()
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        transition.perform(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft, delegate: self),
            by: .presentWithoutNavigationController
        )
    }

    private func sendTransaction(
        from selectAccountViewController: SelectAccountViewController,
        for account: Account
    ) {
        guard let lastTransactionDraft = lastTransactionDraft else {
            return
        }

        var draft = SendTransactionDraft(
            from: account,
            toAccount: lastTransactionDraft.from,
            amount: lastTransactionDraft.amount,
            transactionMode: lastTransactionDraft.transactionMode
        )
        draft.note = lastTransactionDraft.note
        draft.lockedNote = lastTransactionDraft.lockedNote

        let screen: Screen = .sendTransaction(draft: draft)

        selectAccountViewController.open(
            screen,
            by: .push
        )

        clearLastDetectedTransaction()
    }
}

/// <todo>
/// Should be handled for each specific transaction separately.
extension ScanQRFlowCoordinator {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    ) {
        let draft = assetActionConfirmationViewController.draft

        guard let account = draft.account,
              !account.isWatchAccount() else {
            return
        }

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: account,
            assetIndex: Int64(draft.assetId)
        )
        let transactionController = TransactionController(
            api: api,
            bannerController: bannerController
        )

        transactionController.delegate = self
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)
    }
}

/// <todo>
/// Should be handled for each specific transaction separately.
extension ScanQRFlowCoordinator {
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        switch error {
        case let .network(apiError):
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.debugDescription
            )
        default:
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: error.localizedDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        let visibleScreen = presentingScreen.findVisibleScreen()
        visibleScreen.dismissScreen()
    }

    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            bannerController.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(params: amount.toAlgos.toAlgosStringForLabel ?? "")
            )
        case .invalidAddress:
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            let visibleScreen = presentingScreen.findVisibleScreen()
            let bottomTransition = BottomSheetTransition(presentingViewController: visibleScreen)

            bottomTransition.perform(
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
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        let visibleScreen = presentingScreen.findVisibleScreen()
        let ledgerApprovalTransition = BottomSheetTransition(presentingViewController: visibleScreen)
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )
    }

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerApprovalViewController?.dismissScreen()
    }

    func transactionController(
        _ transactionController: TransactionController,
        didCompletedTransaction id: TransactionID
    ) { }

    func transactionControllerDidFailToSignWithLedger(
        _ transactionController: TransactionController
    ) { }
}

extension ScanQRFlowCoordinator {
    private func qrScanner(
        _ qrScannerScreen: QRScannerViewController,
        accountAddressWasDetected qr: QRText
    ) {
        let screen: Screen = .addContact(
            address: qr.address,
            name: qr.label
        )

        presentingScreen.open(
            screen,
            by: .push
        )
    }

    private func qrScanner(
        _ qrScannerScreen: QRScannerViewController,
        algosTransactionWasDetected qr: QRText
    ) {
        saveLastDetectedAlgosTransactionForLater(from: qr)

        let screen: Screen = .accountSelection(
            transactionAction: .send,
            delegate: self
        )

        presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func qrScanner(
        _ qrScannerScreen: QRScannerViewController,
        assetTransactionWasDetected qr: QRText
    ) {
        guard let assetID = qr.asset else {
            return
        }

        guard let asset = findCachedAsset(for: assetID) else {
            let draft = AssetAlertDraft(
                account: nil,
                assetId: assetID,
                asset: nil,
                title: "asset-support-your-add-title".localized,
                detail: "asset-support-your-add-message".localized,
                actionTitle: "title-approve".localized,
                cancelTitle: "title-cancel".localized
            )
            let screen: Screen = .assetActionConfirmation(
                assetAlertDraft: draft,
                delegate: nil
            )

            assetConfirmationTransition =
                BottomSheetTransition(presentingViewController: presentingScreen)
            assetConfirmationTransition?.perform(
                screen,
                by: .presentWithoutNavigationController
            )

            return
        }

        saveLastDetectedAssetTransactionForLater(asset, from: qr)

        let screen: Screen = .accountSelection(
            transactionAction: .send,
            delegate: self
        )

        presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func qrScanner(
        _ qrScannerScreen: QRScannerViewController,
        accountMnemonicWasDetected qr: QRText
    ) {}

    private func qrScanner(
        _ qrScannerScreen: QRScannerViewController,
        assetOptInWasDetected qr: QRText
    ) {
        guard let assetID = qr.asset else {
            return
        }

        let screen: Screen = .accountSelection(
            transactionAction: .optIn(asset: assetID),
            delegate: self
        )

        presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func saveLastDetectedAlgosTransactionForLater(
        from qr: QRText
    ) {
        guard
            let address = qr.address,
            let amount = qr.amount
        else {
            return
        }

        var draft = SendTransactionDraft(
            from: Account(address: address, type: .standard),
            transactionMode: .algo
        )
        draft.note = qr.note
        draft.lockedNote = qr.lockedNote
        draft.amount = amount.toAlgos

        lastTransactionDraft = draft
    }

    private func saveLastDetectedAssetTransactionForLater(
        _ asset: Asset,
        from qr: QRText
    ) {
        guard
            let address = qr.address,
            let amount = qr.amount
        else {
            return
        }

        var draft = SendTransactionDraft(
            from: Account(address: address, type: .standard),
            transactionMode: .asset(asset)
        )
        draft.amount = Decimal(amount)
        draft.note = qr.note
        draft.lockedNote = qr.lockedNote

        lastTransactionDraft = draft
    }

    private func clearLastDetectedTransaction() {
        lastTransactionDraft = nil
    }

    private func findCachedAsset(
        for id: AssetID
    ) -> Asset? {
        for account in sharedDataController.accountCollection {
            if let asset = account.value[id] {
                return asset
            }
        }

        return nil
    }
}
