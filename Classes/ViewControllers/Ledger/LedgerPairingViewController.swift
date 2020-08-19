//
//  LedgerPairingViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

class LedgerPairingViewController: BaseScrollViewController {
    
    private lazy var ledgerPairingView = LedgerPairingView()
    
    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 338.0))
    )
    
    private var keyboard = Keyboard()
    private var contentViewBottomConstraint: Constraint?
    
    private let mode: AccountSetupMode
    
    private lazy var accountManager: AccountManager? = {
        guard let api = self.api else {
            return nil
        }
        let manager = AccountManager(api: api)
        return manager
    }()
    
    private let address: String
    private let connectedDeviceId: UUID
    
    init(mode: AccountSetupMode, address: String, connectedDeviceId: UUID, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.address = address
        self.connectedDeviceId = connectedDeviceId
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "account-details-title".localized
        ledgerPairingView.setAddress(address)
    }
    
    override func setListeners() {
        super.setListeners()
        setKeyboardListeners()
    }
    
    override func linkInteractors() {
        ledgerPairingView.delegate = self
        scrollView.touchDetectingDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerPairingViewLayout()
    }
}

extension LedgerPairingViewController {
    private func setupLedgerPairingViewLayout() {
        contentView.addSubview(ledgerPairingView)
        
        ledgerPairingView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().constraint
        }
    }
}

extension LedgerPairingViewController: LedgerPairingViewDelegate {
    func ledgerPairingViewDidTapCreateAccountButton(_ ledgerPairingView: LedgerPairingView) {
        guard let name = ledgerPairingView.accountNameInputView.inputTextField.text, !name.isEmpty else {
            displaySimpleAlertWith(title: "title-error".localized, message: "account-name-setup-empty-error-message".localized)
            return
        }
        
        if session?.authenticatedUser?.account(address: address) != nil {
            displaySimpleAlertWith(title: "title-error".localized, message: "recover-from-seed-verify-exist-error".localized)
            return
        }
        
        view.endEditing(true)
        
        RegistrationEvent(type: .ledger).logEvent()
        
        let account = setupAccount(with: name)
        presentAccountSetupAlert(for: account)
    }
}

extension LedgerPairingViewController {
    private func presentAccountSetupAlert(for account: AccountInformation) {        
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
    
    private func setupAccount(with name: String) -> AccountInformation {
        let ledgerDetail = LedgerDetail(id: connectedDeviceId, name: nil)
        let account = AccountInformation(address: address, name: name, type: .ledger, ledgerDetail: ledgerDetail)
        let user: User
        
        if let authenticatedUser = session?.authenticatedUser {
            user = authenticatedUser
            user.addAccount(account)
        } else {
            user = User(accounts: [account])
        }
        
        session?.addAccount(Account(address: account.address, type: account.type, ledgerDetail: ledgerDetail, name: account.name))
        session?.authenticatedUser = user
        
        return account
    }
    
    private func launchHome(with account: AccountInformation) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        accountManager?.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            SVProgressHUD.dismiss(withDelay: 1.0) {
                if self.session?.hasPassword() ?? false {
                    switch self.mode {
                    case .initialize:
                        DispatchQueue.main.async {
                            self.dismiss(animated: false) {
                                UIApplication.shared.rootViewController()?.setupTabBarController()
                            }
                        }
                    case .new:
                        self.closeScreen(by: .dismiss, animated: false)
                    case .rekey:
                        break
                    }
                } else {
                    self.open(.choosePassword(mode: .setup, route: nil), by: .push)
                }
            }
        }
    }
}

extension LedgerPairingViewController {
    func setKeyboardListeners() {
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
    }
    
    @objc
    private func didReceive(keyboardWillShow notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let kbHeight = notification.keyboardHeight ?? 0.0
        keyboard.height = kbHeight
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        contentViewBottomConstraint?.update(inset: kbHeight)
        scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        
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
    private func didReceive(keyboardWillHide notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        scrollView.contentInset.bottom = 0.0
        scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        contentViewBottomConstraint?.update(inset: 0.0)
        
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

extension LedgerPairingViewController: TouchDetectingScrollViewDelegate {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if ledgerPairingView.createAccountButton.frame.contains(point) || ledgerPairingView.accountNameInputView.frame.contains(point) {
            return
        }
        contentView.endEditing(true)
    }
}
