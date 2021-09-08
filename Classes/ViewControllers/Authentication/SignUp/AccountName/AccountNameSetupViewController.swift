// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AccountNameSettingViewController.swift

import UIKit
import Macaroon

final class AccountNameSetupViewController: BaseScrollViewController {
    private lazy var accountNameSetupView = AccountNameSetupView()
    private lazy var theme = Theme()
    
    private var keyboardController = KeyboardController()
    
    override func setListeners() {
        super.setListeners()
        keyboardController.beginTracking()
        accountNameSetupView.setListeners()
    }
    
    override func linkInteractors() {
        accountNameSetupView.linkInteractors()
        scrollView.touchDetectingDelegate = self
        keyboardController.dataSource = self
        accountNameSetupView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addAccountNameSetupView()
    }

    override func configureAppearance() {
        super.configureAppearance()
        setNavigationBarTertiaryBackgroundColor()
        customizeBackground()
    }

    private func customizeBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contentView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        accountNameSetupView.beginEditing()
    }
}

extension AccountNameSetupViewController {
    private func addAccountNameSetupView() {
        accountNameSetupView.customize(theme.accountNameSetupViewViewTheme)

        contentView.addSubview(accountNameSetupView)
        accountNameSetupView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AccountNameSetupViewController: AccountNameSetupViewDelegate {
    func accountNameSetupViewDidFinishAccountCreation(_ accountNameSetupView: AccountNameSetupView) {
        setupAccountName()
    }
    
    func accountNameSetupViewDidChangeValue(_ accountNameSetupView: AccountNameSetupView) {}
}

extension AccountNameSetupViewController {
    private func setupAccountName() {
        guard let tempPrivateKey = session?.privateData(for: "temp"),
            let address = session?.address(for: "temp") else {
                return
        }

        log(RegistrationEvent(type: .create))

        let nameInput = accountNameSetupView.accountNameInputView.text.unwrap(or: "")
        let accountName = nameInput.isEmptyOrBlank ? address.shortAddressDisplay() : nameInput
        let account = AccountInformation(address: address, name: accountName, type: .standard)
        session?.savePrivate(tempPrivateKey, for: account.address)
        session?.removePrivateData(for: "temp")
        session?.addAccount(Account(address: account.address, type: account.type, name: account.name))
        
        if let authenticatedUser = session?.authenticatedUser {
            authenticatedUser.addAccount(account)
            closeScreen(by: .dismiss, animated: false)
        } else {
            let user = User(accounts: [account])
            session?.authenticatedUser = user
            
            dismiss(animated: false) {
                UIApplication.shared.rootViewController()?.setupTabBarController()
            }
        }
    }
}

extension AccountNameSetupViewController: KeyboardControllerDataSource {
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 20
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return accountNameSetupView.accountNameInputView
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 20
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
