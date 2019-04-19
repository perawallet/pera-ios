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
        scrollView.touchDetectingDelegate = self
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
        
        setupAccount(name: name)
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
    fileprivate func setupAccount(name: String) {
        guard let tempPrivateKey = session?.privateData(forAccount: "temp"),
            let address = session?.address(forAccount: "temp") else {
                return
        }
        
        let account = Account(address: address)
        
        account.name = name
        
        session?.savePrivate(tempPrivateKey, forAccount: account.address)
        session?.removePrivateData(for: "temp")
        
        if let authenticatedUser = session?.authenticatedUser {
            authenticatedUser.addAccount(account)
            
            closeScreen(by: .dismiss, animated: false) {
                if let accountsViewController = UIApplication.topViewController() as? AccountsViewController,
                    self.session?.authenticatedUser != nil {
                    
                    accountsViewController.newAccount = account
                }
            }
        } else {
            let user = User(accounts: [account])
            user.setDefaultAccount(account)
            
            session?.authenticatedUser = user
            
            open(.home(route: nil), by: .launch)
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
        }
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

// MARK: TouchDetectingScrollViewDelegate

extension AccountNameSetupViewController: TouchDetectingScrollViewDelegate {
    
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if accountNameSetupView.nextButton.frame.contains(point) {
            return
        }
        
        contentView.endEditing(true)
    }
}
