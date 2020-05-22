//
//  SendTransactionPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD
import Magpie
import Alamofire
import CoreBluetooth

class SendTransactionPreviewViewController: BaseScrollViewController {
    
    private(set) lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        )
    )
    
    private lazy var ledgerApprovalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 354.0))
    )
    
    private(set) var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return PushNotificationController(api: api)
    }()
    
    private(set) lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api)
    }()
    
    private(set) lazy var sendTransactionPreviewView = SendTransactionPreviewView(accountType: selectedAccount?.type ?? .standard,
                                                                                  inputFieldFraction: assetFraction)
    var keyboard = Keyboard()
    private(set) var contentViewBottomConstraint: Constraint?
    
    var amount: Double = 0.00
    var selectedAccount: Account?
    var assetReceiverState: AssetReceiverState
    var assetFraction = algosFraction
    
    var shouldUpdateSenderForSelectedAccount = false
    var shouldUpdateReceiverForSelectedAccount = false
    
    var isMaxTransaction: Bool {
        return sendTransactionPreviewView.amountInputView.isMaxButtonSelected
    }
    
    private var timer: Timer?
    
    init(
        account: Account?,
        assetReceiverState: AssetReceiverState,
        configuration: ViewControllerConfiguration
    ) {
        self.selectedAccount = account
        self.assetReceiverState = assetReceiverState
        super.init(configuration: configuration)
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTestNetBanner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        dismissProgressIfNeeded()
        invalidateTimer()
    }
    
    override func setListeners() {
        super.setListeners()
        setKeyboardListeners()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        transactionController.delegate = self
        scrollView.touchDetectingDelegate = self
        sendTransactionPreviewView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupSendTransactionPreviewViewLayout()
    }
    
    func presentAccountList(accountSelectionState: AccountSelectionState) { }
    
    func updateSelectedAccountForSender(_ account: Account) { }
    
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) { }
    
    func displayTransactionPreview() { }
    
    func sendTransactionPreviewViewDidTapMaxButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        sendTransactionPreviewView.amountInputView.inputTextField.text = selectedAccount?.amount.toAlgos.toDecimalStringForAlgosInput
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?) { }
}

extension SendTransactionPreviewViewController {
    private func setupSendTransactionPreviewViewLayout() {
        contentView.addSubview(sendTransactionPreviewView)
        
        sendTransactionPreviewView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(0.0).constraint
        }
    }
    
    func getNoteText() -> String? {
        return sendTransactionPreviewView.noteInputView.inputTextView.text.isEmpty
            ? nil
            : sendTransactionPreviewView.noteInputView.inputTextView.text.addByteLimiter(maximumLimitInByte: 1024)
    }
}

extension SendTransactionPreviewViewController {
    private func displayQRScanner() {
        let qrScannerViewController = open(.qrScanner, by: .push) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
        
    private func displayContactList() {
        let contactsViewController = open(.contactSelection, by: .present) as? ContactsViewController
        contactsViewController?.delegate = self
    }
        
    func getReceiverAccount() -> Account? {
        switch assetReceiverState {
        case let .address(address, _):
            return Account(address: address)
        case let .contact(contact):
            guard let address = contact.address else {
                return nil
            }
            return Account(address: address)
        case let .myAccount(myAccount):
            return myAccount
        case .initial:
            return nil
        }
    }
        
    func isTransactionValid() -> Bool {
        return assetReceiverState != .initial
    }
}

extension SendTransactionPreviewViewController: SendTransactionPreviewViewDelegate {
    func sendTransactionPreviewViewDidTapPreviewButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        view.endEditing(true)
        displayTransactionPreview()
    }
    
    func sendTransactionPreviewViewDidTapCloseButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        sendTransactionPreviewView.transactionReceiverView.state = .initial
    }
    
    func sendTransactionPreviewViewDidTapAddressButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        sendTransactionPreviewView.transactionReceiverView.state = .address(address: "", amount: nil)
        assetReceiverState = .address(address: "", amount: nil)
    }
    
    func sendTransactionPreviewViewDidTapAccountsButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        shouldUpdateReceiverForSelectedAccount = true
        presentAccountList(accountSelectionState: .receiver)
    }
    
    func sendTransactionPreviewViewDidTapContactsButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        view.endEditing(true)
        displayContactList()
    }
    
    func sendTransactionPreviewViewDidTapScanQRButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        view.endEditing(true)
        displayQRScanner()
    }
    
    func sendTransactionPreviewViewDidTapAccountSelectionView(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        shouldUpdateSenderForSelectedAccount = true
        presentAccountList(accountSelectionState: .sender)
    }
}

extension SendTransactionPreviewViewController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        if shouldUpdateReceiverForSelectedAccount {
            shouldUpdateReceiverForSelectedAccount = false
            assetReceiverState = .myAccount(account)
            sendTransactionPreviewView.transactionReceiverView.state = .address(address: account.address, amount: nil)
            return
        }
        
        if shouldUpdateSenderForSelectedAccount {
            shouldUpdateSenderForSelectedAccount = false
            updateSelectedAccountForSender(account)
            selectedAccount = account
        }
    }
}

extension SendTransactionPreviewViewController: ContactsViewControllerDelegate {
    func contactsViewController(_ contactsViewController: ContactsViewController, didSelect contact: Contact) {
        sendTransactionPreviewView.transactionReceiverView.state = .contact(contact)
        assetReceiverState = .contact(contact)
    }
}

extension SendTransactionPreviewViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, then handler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            handler?()
        }
    }
}

extension SendTransactionPreviewViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error) {
        ledgerApprovalViewController?.dismissScreen()
        
        SVProgressHUD.dismiss()
        
        switch error {
        case .networkUnavailable:
            displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
        case let .custom(address):
            if address as? String != nil {
                guard let api = api else {
                    return
                }
                let pushNotificationController = PushNotificationController(api: api)
                pushNotificationController.showFeedbackMessage(
                    "title-error".localized,
                    subtitle: "send-algos-receiver-address-validation".localized
                )
                return
            }
            displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
        default:
            displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
        }
    }
    
    func transactionControllerDidStartBLEConnection(_ transactionController: TransactionController) {
        dismissProgressIfNeeded()
        invalidateTimer()
        
        ledgerApprovalViewController = open(
            .ledgerApproval(mode: .approve),
            by: .customPresent(presentationStyle: .custom, transitionStyle: nil, transitioningDelegate: ledgerApprovalPresenter)
        ) as? LedgerApprovalViewController
    }
    
    func transactionController(_ transactionController: TransactionController, didFailBLEConnectionWith state: CBManagerState) {
        guard let errorTitle = state.errorDescription.title,
            let errorSubtitle = state.errorDescription.subtitle else {
                return
        }
        
        pushNotificationController.showFeedbackMessage(errorTitle, subtitle: errorSubtitle)
        
        invalidateTimer()
        dismissProgressIfNeeded()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailToConnect peripheral: CBPeripheral) {
        ledgerApprovalViewController?.dismissScreen()
        pushNotificationController.showFeedbackMessage("ble-error-connection-title".localized,
                                                       subtitle: "ble-error-fail-connect-peripheral".localized)
    }
    
    func transactionController(_ transactionController: TransactionController, didDisconnectFrom peripheral: CBPeripheral) {
    }
    
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
        pushNotificationController.showFeedbackMessage("ble-error-transaction-cancelled-title".localized,
                                                       subtitle: "ble-error-fail-sign-transaction".localized)
    }
}

// MARK: Ledger Timer
extension SendTransactionPreviewViewController {
    func validateTimer() {
        guard let account = selectedAccount, account.type == .ledger else {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                self.transactionController.stopBLEScan()
                self.dismissProgressIfNeeded()
                self.pushNotificationController.showFeedbackMessage("ble-error-connection-title".localized,
                                                                    subtitle: "ble-error-fail-connect-peripheral".localized)
            }
            
            self.invalidateTimer()
        }
    }
    
    func invalidateTimer() {
        guard let account = selectedAccount, account.type == .ledger else {
            return
        }
        
        timer?.invalidate()
        timer = nil
    }
}

extension SendTransactionPreviewViewController {
    enum AccountSelectionState {
        case sender
        case receiver
    }
}
