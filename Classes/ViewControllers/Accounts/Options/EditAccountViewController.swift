//
//  EditAccountViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit

class EditAccountViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private enum Colors {
        static let backgroundColor = rgb(0.95, 0.96, 0.96)
    }
    
    // MARK: Components
    
    private lazy var editAccountView: EditAccountView = {
        let view = EditAccountView()
        return view
    }()
    
    private var keyboard = Keyboard()
    
    private var contentViewBottomConstraint: Constraint?
    
    fileprivate let account: Account
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
        
        editAccountView.accountNameInputView.inputTextField.text = account.name
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillShow:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    override func linkInteractors() {
        editAccountView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupEditAccountViewLayout()
    }
    
    private func setupEditAccountViewLayout() {
        view.addSubview(editAccountView)
        
        editAccountView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(0.0).constraint
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        editAccountView.accountNameInputView.beginEditing()
    }
    
    @objc
    fileprivate func didReceive(keyboardWillShow notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let kbHeight = notification.keyboardHeight ?? 0.0
        
        keyboard.height = kbHeight
        
        let inset = kbHeight - self.view.safeAreaInsets.bottom
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        self.contentViewBottomConstraint?.update(inset: inset)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [curveAnimationOption],
            animations: {
                self.modalPresenter?.changeModalSize(to: self.modalSize, animated: false)
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    private var modalSize: ModalSize {
        let kbHeight = keyboard.height ?? 0.0
        let size = CGSize(
            width: self.view.bounds.width,
            height: kbHeight + 158.0
        )
        
        return .custom(size)
    }
}

// MARK: EditAccountViewDelegate

extension EditAccountViewController: EditAccountViewDelegate {
    
    func editAccountViewDidTapSaveButton(_ editAccountView: EditAccountView) {
        guard let name = editAccountView.accountNameInputView.inputTextField.text else {
            displaySimpleAlertWith(title: "title-error".localized, message: "account-name-setup-empty-error-message".localized)
            return
        }
        
        account.name = name
        
        session?.authenticatedUser?.updateAccount(account)
        
        dismissScreen()
    }
}
