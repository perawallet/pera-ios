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
        guard let qrScannerViewController = open(.qrScanner, by: .push) as? QRScannerViewController else {
            return
        }
        
        qrScannerViewController.delegate = self
    }
    
    func accountRecoverViewDidTapNextButton(_ accountRecoverView: AccountRecoverView) {
        
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
