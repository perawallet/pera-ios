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

class SendTransactionPreviewViewController: BaseScrollViewController {
    
    private lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        )
    )
    
    private lazy var sendTransactionPreviewView = SendTransactionPreviewView()
    
    private var keyboard = Keyboard()
    
    private var contentViewBottomConstraint: Constraint?
    
    private var amount: Double = 0.00
    private var selectedAccount: Account
    
    private var receiver: AlgosReceiverState
    
    private var shouldUpdateSenderForSelectedAccount = false
    private var shouldUpdateReceiverForSelectedAccount = false
    private var isConnectedToInternet = true
    
    private var isMaxButtonSelected: Bool {
        return self.sendTransactionPreviewView.algosInputView.isMaxButtonSelected
    }
    
    init(account: Account, receiver: AlgosReceiverState, configuration: ViewControllerConfiguration) {
        self.selectedAccount = account
        self.receiver = receiver
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "send-algos-title".localized
        
        sendTransactionPreviewView.accountSelectionView.detailLabel.text = selectedAccount.name
        sendTransactionPreviewView.accountSelectionView.set(amount: selectedAccount.amount.toAlgos)
        sendTransactionPreviewView.algosInputView.maxAmount = selectedAccount.amount.toAlgos
        
        switch receiver {
        case .initial:
            amount = 0.00
            
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        case let .address(_, amount):
            if let sendAmount = amount,
                let amountInt = Int(sendAmount) {
                
                self.amount = amountInt.toAlgos
                sendTransactionPreviewView.algosInputView.inputTextField.text = self.amount.toDecimalStringForLabel
            }
            
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        case .myAccount:
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        case .contact:
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        }
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillShow:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillHide:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        api?.addDelegate(self)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        transactionManager?.delegate = self
        scrollView.touchDetectingDelegate = self
        sendTransactionPreviewView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupSendTransactionPreviewViewLayout()
    }
    
    private func setupSendTransactionPreviewViewLayout() {
        contentView.addSubview(sendTransactionPreviewView)
        
        sendTransactionPreviewView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(view.safeAreaBottom).constraint
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sendTransactionPreviewView.algosInputView.beginEditing()
    }
    
    private func presentAccountList() {
//        let accountListViewController = open(
//            .accountList,
//            by: .customPresent(
//                presentationStyle: .custom,
//                transitionStyle: nil,
//                transitioningDelegate: accountListModalPresenter
//            )
//        ) as? AccountListViewController
//        
//        accountListViewController?.delegate = self
    }
    
    private func displayQRScanner() {
        let qrScannerViewController = open(.qrScanner, by: .push) as? QRScannerViewController
        
        qrScannerViewController?.delegate = self
    }
    
    private func displayContactList() {
        let contactsViewController = open(.contactSelection, by: .push) as? ContactsViewController
        
        contactsViewController?.delegate = self
    }
    
    private func displayTransactionPreview() {
        if !sendTransactionPreviewView.transactionReceiverView.passphraseInputView.inputTextView.text.isEmpty {
            switch receiver {
            case .contact:
                break
            default:
                receiver = .address(
                    address: sendTransactionPreviewView.transactionReceiverView.passphraseInputView.inputTextView.text,
                    amount: nil
                )
            }
        }
        
        if let algosAmountText = sendTransactionPreviewView.algosInputView.inputTextField.text,
            let doubleValue = algosAmountText.doubleForSendSeparator {
            amount = doubleValue
        }
        
        if !isTransactionValid() {
            displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
            return
        }
        
        if selectedAccount.amount <= UInt64(amount.toMicroAlgos) && !isMaxButtonSelected {
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-amount-error".localized)
            return
        }
        
        if !isMaxButtonSelected {
            if Int(selectedAccount.amount) - Int(amount.toMicroAlgos) - Int(minimumFee) < minimumTransactionMicroAlgosLimit {
                self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-minimum-amount-error".localized)
                return
            }
        }
        
        if isMaxButtonSelected {
            if selectedAccount.doesAccountHasParticipationKey() {
                presentAccountRemoveWarning()
                return
            } else if selectedAccount.isThereAnyDifferentAsset() {
                displaySimpleAlertWith(title: "send-algos-account-delete-asset-title".localized, message: "")
                return
            }
        }
        
        composeTransactionData()
    }
    
    private func getAccount() -> Account? {
        let account: Account
        
        switch receiver {
        case let .address(address, _):
            account = Account(address: address)
            
        case let .contact(contact):
            guard let address = contact.address else {
                return nil
            }
            
            account = Account(address: address)
        case let .myAccount(myAccount):
            account = myAccount
        case .initial:
            return nil
        }
        
        return account
    }
    
    private func isTransactionValid() -> Bool {
        if receiver != .initial {
            return true
        }
        
        return false
    }
    
    private func presentAccountRemoveWarning() {
        let alertController = UIAlertController(
            title: "send-algos-account-delete-title".localized,
            message: "send-algos-account-delete-body".localized,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "title-cancel-lowercased".localized, style: .cancel)
        
        let proceedAction = UIAlertAction(title: "title-proceed-lowercased".localized, style: .destructive) { _ in
            self.composeTransactionData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(proceedAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func composeTransactionData() {
        transactionManager?.delegate = self
        if amount.toMicroAlgos < minimumTransactionMicroAlgosLimit {
            var receiverAddress: String
                   
            switch receiver {
            case let .address(address, _):
                receiverAddress = address
            case let .contact(contact):
                guard let contactAddress = contact.address else {
                    self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-contact-not-found".localized)
                    return
                }
                receiverAddress = contactAddress
            case let .myAccount(myAccount):
                receiverAddress = myAccount.address
            case .initial:
                self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-address-not-selected".localized)
                return
            }
                   
            receiverAddress = receiverAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            let receiverFetchDraft = AccountFetchDraft(publicKey: receiverAddress)
                   
            SVProgressHUD.show(withStatus: "title-loading".localized)
            self.api?.fetchAccount(with: receiverFetchDraft) { accountResponse in
                SVProgressHUD.dismiss()
                       
                switch accountResponse {
                case let .failure(error):
                    if !self.isConnectedToInternet {
                        self.displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
                        return
                    }
                    self.displaySimpleAlertWith(title: "title-error".localized, message: error.localizedDescription)
                case let .success(account):
                    if account.amount == 0 {
                        self.displaySimpleAlertWith(title: "title-error".localized,
                                                    message: "send-algos-minimum-amount-error-new-account".localized)
                    } else {
                        let transaction = TransactionPreviewDraft(
                            fromAccount: self.selectedAccount,
                            amount: self.amount,
                            identifier: nil,
                            fee: nil,
                            isMaxTransaction: self.isMaxButtonSelected
                        )
                        
                        guard let account = self.getAccount(),
                            let transactionManager = self.transactionManager else {
                            return
                        }
                               
                        transactionManager.setTransactionDraft(transaction)
                        transactionManager.composeAlgoTransactionData(
                            for: account,
                            isMaxValue: self.isMaxButtonSelected
                        )
                    }
                }
            }
            return
        } else {
            let transaction = TransactionPreviewDraft(
                fromAccount: selectedAccount,
                amount: amount,
                identifier: nil,
                fee: nil,
                isMaxTransaction: isMaxButtonSelected
            )
                   
            guard let account = getAccount(),
                let transactionManager = transactionManager else {
                return
            }
                   
            transactionManager.setTransactionDraft(transaction)
            transactionManager.composeAlgoTransactionData(
                for: account,
                isMaxValue: isMaxButtonSelected
            )
        }
    }
    
    // MARK: Keyboard
    
    @objc
    fileprivate func didReceive(keyboardWillShow notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let kbHeight = notification.keyboardHeight ?? view.safeAreaBottom
        
        keyboard.height = kbHeight
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        if sendTransactionPreviewView.transactionReceiverView.frame.maxY > UIScreen.main.bounds.height - kbHeight - 71.0 {
            scrollView.contentInset.bottom = kbHeight
        } else {
            contentViewBottomConstraint?.update(inset: kbHeight)
        }
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [curveAnimationOption],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    @objc
    fileprivate func didReceive(keyboardWillHide notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        scrollView.contentInset.bottom = 0.0
        
        contentViewBottomConstraint?.update(inset: view.safeAreaBottom)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [curveAnimationOption],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

extension SendTransactionPreviewViewController: SendTransactionPreviewViewDelegate {
    func sendTransactionPreviewViewDidTapAccountSelectionView(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        shouldUpdateSenderForSelectedAccount = true
        presentAccountList()
    }
    
    func sendTransactionPreviewViewDidTapPreviewButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        view.endEditing(true)
        displayTransactionPreview()
    }
    
    func sendTransactionPreviewViewDidTapAddressButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        
    }
    
    func sendTransactionPreviewViewDidTapMyAccountsButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        shouldUpdateReceiverForSelectedAccount = true
        presentAccountList()
    }
    
    func sendTransactionPreviewViewDidTapContactsButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        view.endEditing(true)
        displayContactList()
    }
    
    func sendTransactionPreviewViewDidTapScanQRButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        view.endEditing(true)
        displayQRScanner()
    }
    
    func sendTransactionPreviewViewDidTapMaxButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        sendTransactionPreviewView.algosInputView.inputTextField.text =
            sendTransactionPreviewView.accountSelectionView.algosAmountView.amountLabel.text
    }
}

extension SendTransactionPreviewViewController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        if shouldUpdateReceiverForSelectedAccount {
            shouldUpdateReceiverForSelectedAccount = false
            receiver = .myAccount(account)
            sendTransactionPreviewView.transactionReceiverView.state = .address(address: account.address, amount: nil)
            return
        }
        
        if shouldUpdateSenderForSelectedAccount {
            shouldUpdateSenderForSelectedAccount = false
            sendTransactionPreviewView.accountSelectionView.detailLabel.text = account.name
            sendTransactionPreviewView.accountSelectionView.set(amount: account.amount.toAlgos)
            sendTransactionPreviewView.algosInputView.maxAmount = account.amount.toAlgos
            
            if isMaxButtonSelected {
                sendTransactionPreviewView.algosInputView.inputTextField.text =
                    sendTransactionPreviewView.accountSelectionView.algosAmountView.amountLabel.text
            }
            
            selectedAccount = account
        }
    }
}

extension SendTransactionPreviewViewController: ContactsViewControllerDelegate {
    func contactsViewController(_ contactsViewController: ContactsViewController, didSelect contact: Contact) {
        sendTransactionPreviewView.transactionReceiverView.state = .contact(contact)
        receiver = .contact(contact)
    }
}

extension SendTransactionPreviewViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?) {
        sendTransactionPreviewView.transactionReceiverView.state = .address(address: qrText.text, amount: nil)
        
        if let amountFromQR = qrText.amount,
            amountFromQR != 0 {
            let receivedAmount = amountFromQR.toAlgos
            
            amount = receivedAmount
            
            sendTransactionPreviewView.algosInputView.inputTextField.text = receivedAmount.toDecimalStringForAlgosInput
        }
        
        receiver = .address(address: qrText.text, amount: nil)
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, then handler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = handler {
                handler()
            }
        }
    }
}

extension SendTransactionPreviewViewController: TransactionManagerDelegate {
    func transactionManagerDidComposedAlgoTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: TransactionPreviewDraft?
    ) {
        guard let transactionDraft = draft else {
            return
        }
        open(.sendTransaction(transaction: transactionDraft, receiver: receiver), by: .push)
    }
    
    func transactionManagerDidComposedAssetTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: AssetTransactionDraft?
    ) {
        
    }
    
    func transactionManager(_ transactionManager: TransactionManager, didFailedComposing error: Error) {
        SVProgressHUD.dismiss()
        
        switch error {
        case .networkUnavailable:
            displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
        default:
            displaySimpleAlertWith(title: "title-error".localized, message: error.localizedDescription)
        }
    }
}

extension SendTransactionPreviewViewController: TouchDetectingScrollViewDelegate {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if sendTransactionPreviewView.previewButton.frame.contains(point) ||
            sendTransactionPreviewView.algosInputView.frame.contains(point) ||
            sendTransactionPreviewView.transactionReceiverView.frame.contains(point) {
            
            return
        }
        
        contentView.endEditing(true)
    }
}

extension SendTransactionPreviewViewController: MagpieDelegate {
    func magpie(
        _ magpie: Magpie,
        networkMonitor: NetworkMonitor,
        didConnectVia connection: NetworkConnection,
        from oldConnection: NetworkConnection
    ) {
        isConnectedToInternet = true
    }
    
    func magpie(_ magpie: Magpie, networkMonitor: NetworkMonitor, didDisconnectFrom oldConnection: NetworkConnection) {
        isConnectedToInternet = false
    }
}
