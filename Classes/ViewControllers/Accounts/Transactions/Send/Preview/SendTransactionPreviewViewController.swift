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
    
    private(set) lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api)
    }()
    
    private(set) lazy var sendTransactionPreviewView = SendTransactionPreviewView(account: selectedAccount,
                                                                                  inputFieldFraction: assetFraction)
    var keyboard = Keyboard()
    private(set) var contentViewBottomConstraint: Constraint?
    
    var filterOption: SelectAssetViewController.FilterOption {
        return .none
    }
    
    var amount: Double = 0.00
    var selectedAccount: Account?
    var assetReceiverState: AssetReceiverState
    var assetFraction = algosFraction
    
    var shouldUpdateSenderForSelectedAccount = false
    var shouldUpdateReceiverForSelectedAccount = false
    
    private(set) var isSenderEditable: Bool
    
    var isMaxTransaction: Bool {
        return sendTransactionPreviewView.amountInputView.isMaxButtonSelected
    }
    
    private var timer: Timer?
    
    init(
        account: Account?,
        assetReceiverState: AssetReceiverState,
        isSenderEditable: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.selectedAccount = account
        self.assetReceiverState = assetReceiverState
        self.isSenderEditable = isSenderEditable
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }
        
        if isSenderEditable {
            leftBarButtonItems = [closeBarButtonItem]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedAccount == nil {
            sendTransactionPreviewView.setAssetSelectionHidden(false)
            presentAssetSelection()
        }
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
    
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) { }
    
    func configure(forSelected account: Account, with assetDetail: AssetDetail?) { }
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
            return Account(address: address, type: .standard)
        case let .contact(contact):
            guard let address = contact.address else {
                return nil
            }
            return Account(address: address, type: .standard)
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
        
        guard var account = selectedAccount,
            let session = session else {
            displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-alert-message".localized)
            return
        }
        
        if !session.canSignTransaction(for: &account) {
            return
        }
        
        if isClosingToSameAccount() {
            NotificationBanner.showError("title-error".localized, message: "send-transaction-max-same-account-error".localized)
            return
        }
        
        selectedAccount = account
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
        presentAssetSelection()
    }
    
    func sendTransactionPreviewViewDidTapRemoveButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        sendTransactionPreviewView.setAssetSelectionHidden(!isSenderEditable)
    }
    
    func presentAssetSelection() {
        let controller = open(
            .selectAsset(
                transactionAction: .send,
                filterOption: filterOption
            ),
            by: .present
        ) as? SelectAssetViewController
        controller?.delegate = self
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
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            completionHandler?()
        }
    }
}

extension SendTransactionPreviewViewController: SelectAssetViewControllerDelegate {
    func selectAssetViewController(
        _ selectAssetViewController: SelectAssetViewController,
        didSelectAlgosIn account: Account,
        forAction transactionAction: TransactionAction
    ) {
        configure(forSelected: account, with: nil)
    }
    
    func selectAssetViewController(
        _ selectAssetViewController: SelectAssetViewController,
        didSelect assetDetail: AssetDetail,
        in account: Account,
        forAction transactionAction: TransactionAction
    ) {
        configure(forSelected: account, with: assetDetail)
    }
}

extension SendTransactionPreviewViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPError) {
        ledgerApprovalViewController?.dismissScreen()
        
        SVProgressHUD.dismiss()
        switch error {
        case .network:
            displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
        case let .inapp(errorType):
            guard let transactionError = errorType as? TransactionController.TransactionError else {
                return
            }
            
            displayTransactionError(from: transactionError)
        default:
            displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
        }
    }
    
    private func displayTransactionError(from transactionError: TransactionController.TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            NotificationBanner.showError(
                "asset-min-transaction-error-title".localized,
                message: "send-algos-minimum-amount-custom-error".localized(params: amount.toAlgos.toAlgosStringForLabel ?? "")
            )
        case .invalidAddress:
            NotificationBanner.showError("title-error".localized, message: "send-algos-receiver-address-validation".localized)
        case let .sdkError(error):
            NotificationBanner.showError("title-error".localized, message: error.debugDescription)
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
        NotificationBanner.showError(errorTitle, message: errorSubtitle)
        invalidateTimer()
        dismissProgressIfNeeded()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailToConnect peripheral: CBPeripheral) {
        ledgerApprovalViewController?.dismissScreen()
        NotificationBanner.showError("ble-error-connection-title".localized, message: "ble-error-fail-connect-peripheral".localized)
    }
    
    func transactionController(_ transactionController: TransactionController, didDisconnectFrom peripheral: CBPeripheral) {
    }
    
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
        NotificationBanner.showError(
            "ble-error-transaction-cancelled-title".localized,
            message: "ble-error-fail-sign-transaction".localized
        )
    }
}

// MARK: Ledger Timer
extension SendTransactionPreviewViewController {
    func validateTimer() {
        guard let account = selectedAccount, account.requiresLedgerConnection() else {
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
                NotificationBanner.showError("ble-error-connection-title".localized, message: "ble-error-fail-connect-peripheral".localized)
            }
            
            self.invalidateTimer()
        }
    }
    
    func invalidateTimer() {
        guard let account = selectedAccount, account.requiresLedgerConnection() else {
            return
        }
        
        timer?.invalidate()
        timer = nil
    }
    
    private func isClosingToSameAccount() -> Bool {
        guard let account = selectedAccount,
              let receiverAccount = getReceiverAccount() else {
            return false
        }
        
        return isMaxTransaction && receiverAccount.address == account.address
    }
}

extension SendTransactionPreviewViewController {
    enum AccountSelectionState {
        case sender
        case receiver
    }
}
