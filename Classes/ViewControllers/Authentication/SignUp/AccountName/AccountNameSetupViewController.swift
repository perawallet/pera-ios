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
    
    private lazy var accountNameSetupView = AccountNameSetupView()
    
    private var keyboardController = KeyboardController()
    
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
}

extension AccountNameSetupViewController {
    private func setupAccountNameSetupViewLayout() {
        contentView.addSubview(accountNameSetupView)
        
        accountNameSetupView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AccountNameSetupViewController: AccountNameSetupViewDelegate {
    func accountNameSetupViewDidTapNextButton(_ accountNameSetupView: AccountNameSetupView) {
        guard let name = accountNameSetupView.accountNameInputView.inputTextField.text, !name.isEmpty else {
            self.displaySimpleAlertWith(title: "title-error".localized, message: "account-name-setup-empty-error-message".localized)
            return
        }
        setupAccount(name: name)
    }
    
    func accountNameSetupViewDidChangeValue(_ accountNameSetupView: AccountNameSetupView) {
    }
}

extension AccountNameSetupViewController {
    private func setupAccount(name: String) {
        guard let tempPrivateKey = session?.privateData(for: "temp"),
            let address = session?.address(for: "temp") else {
                return
        }
        
        let account = AccountInformation(address: address, name: name)
        session?.savePrivate(tempPrivateKey, for: account.address)
        session?.removePrivateData(for: "temp")
        session?.addAccount(Account(address: account.address, name: account.name))
        
        if let authenticatedUser = session?.authenticatedUser {
            authenticatedUser.addAccount(account)
            closeScreen(by: .dismiss, animated: false)
        } else {
            let user = User(accounts: [account])
            session?.authenticatedUser = user
            
            self.dismiss(animated: false) {
                UIApplication.shared.rootViewController()?.setupTabBarController()
            }
        }
    }
}

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

extension AccountNameSetupViewController: TouchDetectingScrollViewDelegate {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if accountNameSetupView.nextButton.frame.contains(point) ||
            accountNameSetupView.accountNameInputView.frame.contains(point) {
            return
        }
        contentView.endEditing(true)
    }
}

extension AccountNameSetupViewController {
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
}
