//
//  AccountNameSettingViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum AccountSetupMode {
    case initialize
    case new
}

class AccountNameSetupViewController: BaseScrollViewController {
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    // MARK: Components
    
    private lazy var accountNameSetupView: AccountNameSetupView = {
        let view = AccountNameSetupView()
        return view
    }()
    
    var mode: AccountSetupMode = .initialize
    
    private var keyboardController = KeyboardController()
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "new-account-title".localized
    }
    
    override func setListeners() {
        super.setListeners()
        
        keyboardController.beginTracking()
    }
    
    override func linkInteractors() {
        keyboardController.dataSource = self
        accountNameSetupView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupAccountNameSetupViewLayout()
    }
    
    private func setupAccountNameSetupViewLayout() {
        contentView.addSubview(accountNameSetupView)
        
        accountNameSetupView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: AccountNameSetupViewDelegate

extension AccountNameSetupViewController: AccountNameSetupViewDelegate {
    
    func accountNameSetupViewDidTapNextButton(_ accountNameSetupView: AccountNameSetupView) {
        guard let name = accountNameSetupView.accountNameInputView.inputTextField.text, !name.isEmpty else {
            self.displaySimpleAlertWith(title: "title-error".localized, message: "account-name-setup-empty-error-message".localized)
            return
        }
        
        switch mode {
        case .initialize:
            setupInitialAccount(name: name)
        case .new:
            setupNewAccount(name: name)
        }
    }
    
    func accountNameSetupViewDidChangeValue(_ accountNameSetupView: AccountNameSetupView) {
        if let text = accountNameSetupView.accountNameInputView.inputTextField.text,
            !text.isEmpty {
            
            accountNameSetupView.accountNameInputView.separatorView.backgroundColor = SharedColors.blue
            return
        }
        
        accountNameSetupView.accountNameInputView.separatorView.backgroundColor = Colors.separatorColor
    }
}

// MARK: - Helpers
extension AccountNameSetupViewController {
    fileprivate func setupInitialAccount(name: String) {
        guard let tempPrivateKey = session?.privateData(forAccount: "temp"),
            let address = session?.address(forAccount: "temp") else {
                return
        }
        
        let account = Account(address: address)
        
        account.name = name
        
        session?.savePrivate(tempPrivateKey, forAccount: account.address)
        session?.removePrivateData(for: "temp")
        
        let user = User(accounts: [account])
        
        let isAccountDefault = session?.authenticatedUser == nil
        
        if isAccountDefault {
            user.setDefaultAccount(account)
        }
        
        session?.authenticatedUser = user
        
        open(.home, by: .launch)
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
        }
    }
    
    fileprivate func setupNewAccount(name: String) {
        guard let generatedData = session?.generatePrivateKey(),
            let address = session?.address(fromPrivateKey: generatedData) else {
            return
        }
        
        let account = Account(address: address)
        account.name = name
        
        guard let accountData = account.encoded() else {
            return
        }
        
        session?.savePrivate(generatedData, forAccount: "temp")
        session?.savePrivate(accountData, forAccount: "tempAccount")
        
        open(.passPhraseBackUp(mode: mode), by: .push)
    }
}

// MARK: KeyboardControllerDataSource

extension AccountNameSetupViewController: KeyboardControllerDataSource {
    
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return accountNameSetupView.nextButton
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
}
