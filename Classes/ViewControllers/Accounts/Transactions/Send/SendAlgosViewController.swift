//
//  SendAlgosViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

class SendAlgosViewController: BaseScrollViewController {
    
    // MARK: Variables
    
    private lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        )
    )
    
    // MARK: Components
    
    private lazy var sendAlgosView: SendAlgosView = {
        let view = SendAlgosView()
        return view
    }()
    
    private var keyboard = Keyboard()
    private lazy var transactionManager = TransactionManager(api: api)
    private var contentViewBottomConstraint: Constraint?
    
    private var amount: Double = 0.00
    private var selectedAccount: Account
    
    private var receiver: AlgosReceiverState
    
    private var shouldUpdateSenderForSelectedAccount = false
    private var shouldUpdateReceiverForSelectedAccount = false
    
    private var isMaxButtonSelected: Bool {
        return self.sendAlgosView.algosInputView.isMaxButtonSelected
    }
    
    // MARK: Initialization
    
    init(account: Account, receiver: AlgosReceiverState, configuration: ViewControllerConfiguration) {
        self.selectedAccount = account
        self.receiver = receiver
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "send-algos-title".localized
        
        sendAlgosView.accountSelectionView.detailLabel.text = selectedAccount.name
        sendAlgosView.accountSelectionView.set(amount: selectedAccount.amount.toAlgos)
        sendAlgosView.algosInputView.maxAmount = selectedAccount.amount.toAlgos
        
        switch receiver {
        case .initial:
            amount = 0.00
            
            sendAlgosView.transactionReceiverView.state = receiver
        case let .address(_, amount):
            if let sendAmount = amount,
                let amountInt = Int(sendAmount) {
                
                self.amount = amountInt.toAlgos
                sendAlgosView.algosInputView.inputTextField.text = self.amount.toDecimalStringForLabel
            }
            
            sendAlgosView.transactionReceiverView.state = receiver
        case .myAccount:
            sendAlgosView.transactionReceiverView.state = receiver
        case .contact:
            sendAlgosView.transactionReceiverView.state = receiver
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
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        transactionManager.delegate = self
        scrollView.touchDetectingDelegate = self
        sendAlgosView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupSendAlgosViewLayout()
    }
    
    private func setupSendAlgosViewLayout() {
        contentView.addSubview(sendAlgosView)
        
        sendAlgosView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(view.safeAreaBottom).constraint
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sendAlgosView.algosInputView.beginEditing()
    }
    
    // MARK: Navigation
    
    private func presentAccountList() {
        let accountListViewController = open(
            .accountList,
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        ) as? AccountListViewController
        
        accountListViewController?.delegate = self
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
        if !sendAlgosView.transactionReceiverView.passphraseInputView.inputTextView.text.isEmpty {
            switch receiver {
            case .contact:
                break
            default:
                receiver = .address(address: sendAlgosView.transactionReceiverView.passphraseInputView.inputTextView.text, amount: nil)
            }
        }
        
        if let algosAmountText = sendAlgosView.algosInputView.inputTextField.text,
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
            if selectedAccount.amount - UInt64(amount.toMicroAlgos) - minimumFee < minimumTransactionMicroAlgosLimit {
                self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-minimum-amount-error".localized)
                return
            }
        }
        
        if amount.toMicroAlgos < minimumTransactionMicroAlgosLimit {
            let receiverAddress: String
            
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
            
            let receiverFetchDraft = AccountFetchDraft(publicKey: receiverAddress)
            
            SVProgressHUD.show(withStatus: "title-loading".localized)
            self.api?.fetchAccount(with: receiverFetchDraft) { accountResponse in
                SVProgressHUD.dismiss()
                
                switch accountResponse {
                case let .failure(error):
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
                            fee: nil
                        )
                        
                        self.transactionManager.transaction = transaction
                        self.transactionManager.composeTransactionData(
                            for: self.selectedAccount,
                            isMaxValue: self.isMaxButtonSelected
                        )
                    }
                }
            }
            
            return
        } else {
            let transaction = TransactionPreviewDraft(fromAccount: selectedAccount, amount: amount, identifier: nil, fee: nil)
            
            self.transactionManager.transaction = transaction
            self.transactionManager.composeTransactionData(
                for: self.selectedAccount,
                isMaxValue: isMaxButtonSelected
            )
        }
    }
    
    private func isTransactionValid() -> Bool {
        if receiver != .initial {
            return true
        }
        
        return false
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
        
        if sendAlgosView.transactionReceiverView.frame.maxY > UIScreen.main.bounds.height - kbHeight - 71.0 {
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

// MARK: SendAlgosViewDelegate

extension SendAlgosViewController: SendAlgosViewDelegate {
    
    func sendAlgosViewDidTapAccountSelectionView(_ sendAlgosView: SendAlgosView) {
        shouldUpdateSenderForSelectedAccount = true
        presentAccountList()
    }
    
    func sendAlgosViewDidTapPreviewButton(_ sendAlgosView: SendAlgosView) {
        view.endEditing(true)
        
        displayTransactionPreview()
    }
    
    func sendAlgosViewDidTapAddressButton(_ sendAlgosView: SendAlgosView) {
        
    }
    
    func sendAlgosViewDidTapMyAccountsButton(_ sendAlgosView: SendAlgosView) {
        shouldUpdateReceiverForSelectedAccount = true
        presentAccountList()
    }
    
    func sendAlgosViewDidTapContactsButton(_ sendAlgosView: SendAlgosView) {
        view.endEditing(true)
        
        displayContactList()
    }
    
    func sendAlgosViewDidTapScanQRButton(_ sendAlgosView: SendAlgosView) {
        view.endEditing(true)
        
        displayQRScanner()
    }
    
    func sendAlgosViewDidTapMaxButton(_ sendAlgosView: SendAlgosView) {
        sendAlgosView.algosInputView.inputTextField.text = sendAlgosView.accountSelectionView.algosAmountView.amountLabel.text
    }
}

// MARK: AccountListViewControllerDelegate

extension SendAlgosViewController: AccountListViewControllerDelegate {
    
    func accountListViewControllerDidTapAddButton(_ viewController: AccountListViewController) {
    }
    
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        if shouldUpdateReceiverForSelectedAccount {
            shouldUpdateReceiverForSelectedAccount = false
            receiver = .myAccount(account)
            sendAlgosView.transactionReceiverView.state = .address(address: account.address, amount: nil)
            sendAlgosView.algosInputView.maxAmount = account.amount.toAlgos
            if isMaxButtonSelected {
                sendAlgosView.algosInputView.inputTextField.text = sendAlgosView.accountSelectionView.algosAmountView.amountLabel.text
            }
            return
        }
        
        if shouldUpdateSenderForSelectedAccount {
            shouldUpdateSenderForSelectedAccount = false
            sendAlgosView.accountSelectionView.detailLabel.text = account.name
            sendAlgosView.accountSelectionView.set(amount: account.amount.toAlgos)
            sendAlgosView.algosInputView.maxAmount = account.amount.toAlgos
            
            if isMaxButtonSelected {
                sendAlgosView.algosInputView.inputTextField.text = sendAlgosView.accountSelectionView.algosAmountView.amountLabel.text
            }
            
            selectedAccount = account
        }
    }
}

// MARK: AccountListViewControllerDelegate

extension SendAlgosViewController: ContactsViewControllerDelegate {
    
    func contactsViewController(_ contactsViewController: ContactsViewController, didSelect contact: Contact) {
        sendAlgosView.transactionReceiverView.state = .contact(contact)

        receiver = .contact(contact)
    }
}

// MARK: QRScannerViewControllerDelegate

extension SendAlgosViewController: QRScannerViewControllerDelegate {
    
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?) {
        sendAlgosView.transactionReceiverView.state = .address(address: qrText.text, amount: nil)
        
        if let amountFromQR = qrText.amount,
            amountFromQR != 0 {
            let receivedAmount = amountFromQR.toAlgos
            
            amount = receivedAmount
            
            sendAlgosView.algosInputView.inputTextField.text = receivedAmount.toDecimalStringForAlgosInput
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

// MARK: SendAlgosPreviewViewControllerDelegate

extension SendAlgosViewController: SendAlgosPreviewViewControllerDelegate {
    
    func sendAlgosPreviewViewControllerDidTapSendMoreButton(
        _ sendAlgosPreviewViewController: SendAlgosPreviewViewController,
        withReceiver state: AlgosReceiverState
    ) {
        resetView(for: state)
    }
    
    private func resetView(for state: AlgosReceiverState) {
        amount = 0.00
        sendAlgosView.algosInputView.inputTextField.text = nil
        receiver = state
        sendAlgosView.transactionReceiverView.state = state
    }
}

// MARK: TransactionManagerDelegate

extension SendAlgosViewController: TransactionManagerDelegate {
    func transactionManagerDidComposedTransactionData(_ transactionManager: TransactionManager) {
        guard let transaction = transactionManager.transaction else {
            return
        }
        
        let sendAlgosPreviewViewController = open(
            .sendAlgosPreview(manager: transactionManager, transaction: transaction, receiver: receiver),
            by: .push
        ) as? SendAlgosPreviewViewController
        
        sendAlgosPreviewViewController?.delegate = self
    }
    
    func transactionManagerDidFailedComposingTransactionData(_ transactionManager: TransactionManager) {
        
    }
}

// MARK: TouchDetectingScrollViewDelegate

extension SendAlgosViewController: TouchDetectingScrollViewDelegate {
    
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if sendAlgosView.previewButton.frame.contains(point) ||
            sendAlgosView.algosInputView.frame.contains(point) ||
            sendAlgosView.transactionReceiverView.frame.contains(point) {
            
            return
        }
        
        contentView.endEditing(true)
    }
}
