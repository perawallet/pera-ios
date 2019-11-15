//
//  AccountRecoverViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

class AccountRecoverViewController: BaseScrollViewController {
    
    // MARK: Components
    
    private lazy var accountRecoverView: AccountRecoverView = {
        let view = AccountRecoverView()
        return view
    }()
    
    private var keyboardController = KeyboardController()
    
    private lazy var accountManager: AccountManager? = {
        guard let api = self.api,
            let user = session?.authenticatedUser  else {
                return nil
        }
        
        let manager = AccountManager(api: api)
        manager.user = user
        return manager
    }()
    
    var mode: AccountSetupMode = .initialize

    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "recover-from-seed-title".localized
    }
    
    override func setListeners() {
        super.setListeners()
        
        keyboardController.beginTracking()
    }
    
    override func linkInteractors() {
        keyboardController.dataSource = self
        accountRecoverView.delegate = self
        scrollView.touchDetectingDelegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupAccountRecoverViewLayout()
    }
    
    private func setupAccountRecoverViewLayout() {
        contentView.addSubview(accountRecoverView)
        
        accountRecoverView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: AccountRecoverViewDelegate

extension AccountRecoverViewController: AccountRecoverViewDelegate {
    
    func accountRecoverViewDidTapQRCodeButton(_ accountRecoverView: AccountRecoverView) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displaySimpleAlertWith(title: "qr-scan-error-title".localized, message: "qr-scan-error-message".localized)
            return
        }
        
        guard let qrScannerViewController = open(.qrScanner, by: .push) as? QRScannerViewController else {
            return
        }
        
        qrScannerViewController.delegate = self
    }
    
    func accountRecoverViewDidTapNextButton(_ accountRecoverView: AccountRecoverView) {
        guard let name = accountRecoverView.accountNameInputView.inputTextField.text, !name.isEmpty else {
            displaySimpleAlertWith(title: "title-error".localized, message: "account-name-setup-empty-error-message".localized)
            return
        }
        
        guard let mnemonics = accountRecoverView.passPhraseInputView.inputTextView.text,
            let privateKey = session?.privateKey(forMnemonics: mnemonics) else {
                displaySimpleAlertWith(title: "title-error".localized,
                                       message: "pass-phrase-verify-invalid-passphrase".localized)
                return
        }
        
        guard let address = session?.address(fromPrivateKey: privateKey) else {
            displaySimpleAlertWith(title: "title-error".localized,
                                   message: "pass-phrase-verify-sdk-error".localized)
            return
        }
        
        guard session?.authenticatedUser?.account(address: address) == nil else {
            displaySimpleAlertWith(title: "title-error".localized,
                                   message: "recover-from-seed-verify-exist-error".localized)
            return
        }
        
        let account = Account(address: address)
        account.name = name
        
        session?.savePrivate(privateKey, forAccount: account.address)
        
        let user: User
        
        if let authenticatedUser = session?.authenticatedUser {
            user = authenticatedUser
            
            user.addAccount(account)
        } else {
            user = User(accounts: [account])
        }
        
        session?.authenticatedUser = user
        
        accountManager?.user = user
        
        view.endEditing(true)
        
        let configurator = AlertViewConfigurator(
            title: "recover-from-seed-verify-pop-up-title".localized,
            image: img("account-verify-alert-icon"),
            explanation: "recover-from-seed-verify-pop-up-explanation".localized,
            actionTitle: nil) {
                self.launchHome(with: account)
        }
        
        let viewController = AlertViewController(mode: .default, alertConfigurator: configurator, configuration: configuration)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        
        present(viewController, animated: true, completion: nil)
    }
    
    fileprivate func launchHome(with account: Account) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        
        self.accountManager?.fetchAllAccounts {
            
            SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
            
            SVProgressHUD.dismiss(withDelay: 1.0) {
                if self.session?.hasPassword() ?? false {
                    switch self.mode {
                    case .initialize:
                        self.dismiss(animated: false) {
                            UIApplication.shared.rootViewController()?.setupTabBarController()
                        }
                    case .new:
                        self.closeScreen(by: .dismiss, animated: false) {
                            if self.session?.authenticatedUser != nil {
                                UIApplication.shared.rootViewController()?.addAccount(account)
                            }
                        }
                    }
                } else {
                    self.open(.choosePassword(mode: .setup, route: nil), by: .push)
                }
            }
        }
    }
}

// MARK: QRScannerViewControllerDelegate

extension AccountRecoverViewController: QRScannerViewControllerDelegate {
    
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?) {
        
        guard qrText.mode == .mnemonic else {
            displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-mnemonics-message".localized) { _ in
                if let handler = handler {
                    handler()
                }
            }
            
            return
        }
        
        accountRecoverView.passPhraseInputView.value = qrText.text
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, then handler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = handler {
                handler()
            }
        }
    }
}

// MARK: KeyboardControllerDataSource

extension AccountRecoverViewController: KeyboardControllerDataSource {
    
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return accountRecoverView.accountNameInputView
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 0.0
    }
}

// MARK: TouchDetectingScrollViewDelegate

extension AccountRecoverViewController: TouchDetectingScrollViewDelegate {
    
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if accountRecoverView.nextButton.frame.contains(point) {
            return
        }
        
        contentView.endEditing(true)
    }
}
