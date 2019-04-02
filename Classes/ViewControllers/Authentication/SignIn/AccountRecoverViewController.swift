//
//  AccountRecoverViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountRecoverViewController: BaseScrollViewController {
    
    // MARK: Components
    
    private lazy var accountRecoverView: AccountRecoverView = {
        let view = AccountRecoverView()
        return view
    }()
    
    private var keyboardController = KeyboardController()
    
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
        
        let account = Account(address: address)
        account.name = name
        
        session?.savePrivate(privateKey, forAccount: account.address)
        
        let user: User
        
        if let authenticatedUser = session?.authenticatedUser {
            user = authenticatedUser
            
            user.addAccount(account)
        } else {
            user = User(accounts: [account])
            
            user.setDefaultAccount(account)
        }
        
        session?.authenticatedUser = user
        
        view.endEditing(true)
        
        let configurator = AlertViewConfigurator(
            title: "recover-from-seed-verify-pop-up-title".localized,
            image: img("account-verify-alert-icon"),
            explanation: "recover-from-seed-verify-pop-up-explanation".localized,
            actionTitle: nil) {
                if self.session?.hasPassword() ?? false {
                    switch self.mode {
                    case .initialize:
                        self.open(.home, by: .launch)
                    case .new:
                        self.dismissScreen()
                    }
                } else {
                    self.open(.choosePassword(.setup), by: .push)
                }
        }
        
        let viewController = AlertViewController(mode: .default, alertConfigurator: configurator, configuration: configuration)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: QRScannerViewControllerDelegate

extension AccountRecoverViewController: QRScannerViewControllerDelegate {
    
    func qRScannerViewController(_ controller: QRScannerViewController, didRead qrCode: String) {
        
        accountRecoverView.passPhraseInputView.value = qrCode
    }
}

// MARK: KeyboardControllerDataSource

extension AccountRecoverViewController: KeyboardControllerDataSource {
    
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return accountRecoverView.nextButton
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 0.0
    }
}
