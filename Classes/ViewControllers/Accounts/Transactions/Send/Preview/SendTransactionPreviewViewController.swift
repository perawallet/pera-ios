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
    
    private(set) lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        )
    )
    
    private(set) lazy var sendTransactionPreviewView = SendTransactionPreviewView()
    
    private var keyboard = Keyboard()
    private var contentViewBottomConstraint: Constraint?
    
    var amount: Double = 0.00
    var selectedAccount: Account
    var receiver: AlgosReceiverState
    
    private(set) var isConnectedToInternet = true
    
    var isMaxButtonSelected: Bool {
        return self.sendTransactionPreviewView.amountInputView.isMaxButtonSelected
    }
    
    init(
        account: Account,
        receiver: AlgosReceiverState,
        configuration: ViewControllerConfiguration
    ) {
        self.selectedAccount = account
        self.receiver = receiver
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sendTransactionPreviewView.amountInputView.beginEditing()
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
    
    func presentAccountList() {
        
    }
    
    func transactionManagerDidComposedAlgoTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: TransactionPreviewDraft?
    ) {
        
    }
    
    func transactionManagerDidComposedAssetTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: AssetTransactionDraft?
    ) {
        
    }
    
    func displayTransactionPreview() {
        
    }
    
    func sendTransactionPreviewViewDidTapMaxButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        sendTransactionPreviewView.amountInputView.inputTextField.text = selectedAccount.amount.toAlgos.toDecimalStringForAlgosInput
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?) {
        
    }
}

extension SendTransactionPreviewViewController {
    private func setupSendTransactionPreviewViewLayout() {
        contentView.addSubview(sendTransactionPreviewView)
        
        sendTransactionPreviewView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(view.safeAreaBottom).constraint
        }
    }
}

extension SendTransactionPreviewViewController {
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

extension SendTransactionPreviewViewController {
    private func displayQRScanner() {
        let qrScannerViewController = open(.qrScanner, by: .push) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
        
    private func displayContactList() {
        let contactsViewController = open(.contactSelection, by: .push) as? ContactsViewController
        contactsViewController?.delegate = self
    }
        
    func getAccount() -> Account? {
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
        
    func isTransactionValid() -> Bool {
        if receiver != .initial {
            return true
        }
        return false
    }
}

extension SendTransactionPreviewViewController: SendTransactionPreviewViewDelegate {
    func sendTransactionPreviewViewDidTapPreviewButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        view.endEditing(true)
        displayTransactionPreview()
    }
    
    func sendTransactionPreviewViewDidTapAddressButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        
    }
    
    func sendTransactionPreviewViewDidTapMyAccountsButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
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
}

extension SendTransactionPreviewViewController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        receiver = .myAccount(account)
        sendTransactionPreviewView.transactionReceiverView.state = .address(address: account.address, amount: nil)
    }
}

extension SendTransactionPreviewViewController: ContactsViewControllerDelegate {
    func contactsViewController(_ contactsViewController: ContactsViewController, didSelect contact: Contact) {
        sendTransactionPreviewView.transactionReceiverView.state = .contact(contact)
        receiver = .contact(contact)
    }
}

extension SendTransactionPreviewViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, then handler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = handler {
                handler()
            }
        }
    }
}

extension SendTransactionPreviewViewController: TransactionManagerDelegate {
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
            sendTransactionPreviewView.amountInputView.frame.contains(point) ||
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
