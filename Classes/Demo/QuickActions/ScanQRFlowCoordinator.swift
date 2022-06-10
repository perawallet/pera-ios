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
    SelectAccountViewControllerDelegate {
    private var lastTransactionDraft: SendTransactionDraft?
    private var assetConfirmationTransition: BottomSheetTransition?

    private unowned let presentingScreen: UIViewController
    private let sharedDataController: SharedDataController

    init(
        sharedDataController: SharedDataController,
        presentingScreen: UIViewController
    ) {
        self.sharedDataController = sharedDataController
        self.presentingScreen = presentingScreen
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
        }
    }

    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    ) {
//        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
//            if let handler = completionHandler {
//                handler()
//            }
//        }
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
