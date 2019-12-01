//
//  ReceiveAlgosViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit

class RequestAlgosViewController: BaseViewController {
    
    // MARK: Variables
    
    private lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        )
    )
    
    // MARK: Components
    
    private lazy var requestAlgosView: RequestAlgosView = {
        let view = RequestAlgosView()
        return view
    }()
    
    private var keyboard = Keyboard()
    
    private var contentViewBottomConstraint: Constraint?
    
    private var amount: Double = 0.00
    private var selectedAccount: Account

    // MARK: Initialization
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.selectedAccount = account
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "request-algos-title".localized
        
        requestAlgosView.accountSelectionView.detailLabel.text = selectedAccount.name
        requestAlgosView.accountSelectionView.set(amount: selectedAccount.amount.toAlgos)
    }
    
    override func setListeners() {
        super.setListeners()
        
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
    
    override func linkInteractors() {
        requestAlgosView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupRequestAlgosViewLayout()
    }
    
    private func setupRequestAlgosViewLayout() {
        view.addSubview(requestAlgosView)
        
        requestAlgosView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(view.safeAreaBottom).constraint
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestAlgosView.algosInputView.beginEditing()
    }
    
    // MARK: Navigation
    
    private func presentAccountList() {
//        let accountListViewController = open(
//            .accountList,
//            by: .customPresent(
//                presentationStyle: .custom,
//                transitionStyle: nil,
//                transitioningDelegate: accountListModalPresenter
//            )
//            ) as? AccountListViewController
//        
//        accountListViewController?.delegate = self
    }
    
    private func displayPreview() {
        if let algosAmountText = requestAlgosView.algosInputView.inputTextField.text,
            let doubleValue = algosAmountText.doubleForSendSeparator {
            amount = doubleValue
        }
        
        if !isTransactionValid() {
            displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
        }
        
        view.endEditing(true)
        
        let transaction = TransactionPreviewDraft(fromAccount: selectedAccount, amount: amount, identifier: nil, fee: nil)
        
        open(.requestAlgosPreview(transaction: transaction), by: .push)
    }
    
    private func isTransactionValid() -> Bool {
        if amount > 0.0 {
            return true
        }
        
        return false
    }
    
    // MARK: Keyboard
    
    @objc
    fileprivate func didReceive(keyboardWillShow notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let kbHeight = notification.keyboardHeight ?? view.safeAreaBottom
        
        keyboard.height = kbHeight
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        contentViewBottomConstraint?.update(inset: kbHeight)
        
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
    fileprivate func didReceive(keyboardWillHide notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        contentViewBottomConstraint?.update(inset: view.safeAreaBottom)
        
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

// MARK: RequestAlgosViewDelegate

extension RequestAlgosViewController: RequestAlgosViewDelegate {
    
    func requestAlgosViewDidTapAccountSelectionView(_ requestAlgosView: RequestAlgosView) {
        presentAccountList()
    }
    
    func requestAlgosViewDidTapPreviewButton(_ requestAlgosView: RequestAlgosView) {
        displayPreview()
    }
}

// MARK: AccountListViewControllerDelegate

extension RequestAlgosViewController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        requestAlgosView.accountSelectionView.detailLabel.text = account.name
        requestAlgosView.accountSelectionView.set(amount: account.amount.toAlgos)
        
        selectedAccount = account
    }
}
