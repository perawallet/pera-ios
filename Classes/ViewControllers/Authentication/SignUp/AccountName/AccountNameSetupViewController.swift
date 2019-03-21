//
//  AccountNameSettingViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountNameSetupViewController: BaseScrollViewController {
    
    // MARK: Components
    
    private lazy var accountNameSetupView: AccountNameSetupView = {
        let view = AccountNameSetupView()
        return view
    }()
    
    private var keyboardController = KeyboardController()
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        view.backgroundColor = rgb(0.97, 0.97, 0.98)
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
        
        shouldIgnoreBottomLayoutGuide = false
        
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
        
    }
    
    func accountNameSetupViewDidChangeValue(_ accountNameSetupView: AccountNameSetupView) {
        if let text = accountNameSetupView.accountNameInputView.inputTextField.text,
            !text.isEmpty {
            
            accountNameSetupView.accountNameInputView.separatorView.backgroundColor = rgb(0.0, 0.46, 1.0)
            return
        }
        
        accountNameSetupView.accountNameInputView.separatorView.backgroundColor = rgba(0.67, 0.67, 0.72, 0.31)
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
