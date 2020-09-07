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
    
    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 338.0))
    )
    
    private lazy var accountRecoverView = AccountRecoverView()
    
    private var keyboardController = KeyboardController()
    
    private lazy var accountManager: AccountManager? = {
        guard let api = self.api else {
            return nil
        }
        let manager = AccountManager(api: api)
        return manager
    }()
    
    private let accountSetupFlow: AccountSetupFlow
    
    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }
    
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
    
    override func prepareLayout() {
        super.prepareLayout()
        setupAccountRecoverViewLayout()
    }
}

extension AccountRecoverViewController {
    private func setupAccountRecoverViewLayout() {
        contentView.addSubview(accountRecoverView)
        
        accountRecoverView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

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
                displaySimpleAlertWith(title: "title-error".localized, message: "pass-phrase-verify-invalid-passphrase".localized)
                return
        }
        
        guard let address = session?.address(fromPrivateKey: privateKey) else {
            displaySimpleAlertWith(title: "title-error".localized, message: "pass-phrase-verify-sdk-error".localized)
            return
        }
        
        let account: AccountInformation
        
        if let sameAccount = session?.account(from: address) {
            if sameAccount.isRekeyed() {
                account = AccountInformation(address: address, name: name, type: .rekeyed, ledgerDetail: sameAccount.ledgerDetail)
            } else {
                displaySimpleAlertWith(title: "title-error".localized, message: "recover-from-seed-verify-exist-error".localized)
                return
            }
        } else {
            account = AccountInformation(address: address, name: name)
        }
        
        session?.savePrivate(privateKey, for: account.address)
        
        let user: User
        
        if let authenticatedUser = session?.authenticatedUser {
            user = authenticatedUser
            
            if session?.authenticatedUser?.account(address: address) != nil {
                user.updateAccount(account)
            } else {
                user.addAccount(account)
            }
        } else {
            user = User(accounts: [account])
        }
        
        session?.addAccount(Account(accountInformation: account))
        session?.authenticatedUser = user
        
        view.endEditing(true)
        
        RegistrationEvent(type: .recover).logEvent()
        
        let configurator = BottomInformationBundle(
            title: "recover-from-seed-verify-pop-up-title".localized,
            image: img("img-green-checkmark"),
            explanation: "recover-from-seed-verify-pop-up-explanation".localized,
            actionTitle: "title-go-home".localized,
            actionImage: img("bg-main-button")) {
                self.launchHome(with: account)
        }
        
        open(
            .bottomInformation(mode: .confirmation, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: bottomModalPresenter
            )
        )
    }
    
    private func launchHome(with account: AccountInformation) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        accountManager?.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            SVProgressHUD.dismiss(withDelay: 1.0) {
                switch self.accountSetupFlow {
                case .initializeAccount:
                    DispatchQueue.main.async {
                        self.dismiss(animated: false) {
                            UIApplication.shared.rootViewController()?.setupTabBarController()
                        }
                    }
                case .addNewAccount:
                    self.closeScreen(by: .dismiss, animated: false)
                }
            }
        }
    }
}

extension AccountRecoverViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        guard qrText.mode == .mnemonic else {
            displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-mnemonics-message".localized) { _ in
                if let handler = completionHandler {
                    handler()
                }
            }
            
            return
        }
        accountRecoverView.passPhraseInputView.value = qrText.qrText()
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = completionHandler {
                handler()
            }
        }
    }
}

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

extension AccountRecoverViewController: TouchDetectingScrollViewDelegate {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if accountRecoverView.nextButton.frame.contains(point) ||
            accountRecoverView.accountNameInputView.frame.contains(point) ||
            accountRecoverView.passPhraseInputView.frame.contains(point) {
            return
        }
        contentView.endEditing(true)
    }
}
