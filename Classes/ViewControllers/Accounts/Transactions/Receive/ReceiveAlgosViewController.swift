//
//  ReceiveAlgosViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit

class ReceiveAlgosViewController: BaseViewController {
    
    // MARK: Variables
    
    private lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
        )
    )
    
    // MARK: Components
    
    private lazy var receiveAlgosView: ReceiveAlgosView = {
        let view = ReceiveAlgosView()
        return view
    }()
    
    private var keyboard = Keyboard()
    
    private var contentViewBottomConstraint: Constraint?
    
    private var amount: Double = 0.00
    private var selectedAccount: Account?

    // MARK: Initialization
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "receive-algos-title".localized
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
        receiveAlgosView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupReceiveAlgosViewLayout()
    }
    
    private func setupReceiveAlgosViewLayout() {
        view.addSubview(receiveAlgosView)
        
        receiveAlgosView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(view.safeAreaBottom).constraint
        }
    }
    
    // MARK: Navigation
    
    private func presentAccountList() {
        let accountListViewController = open(
            .accountList(mode: .onlyList),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
            ) as? AccountListViewController
        
        accountListViewController?.delegate = self
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
        
        if receiveAlgosView.accountSelectionView.frame.maxY + 71 > UIScreen.main.bounds.height - kbHeight {
            contentViewBottomConstraint?.update(inset: kbHeight - 50.0)
        } else {
            contentViewBottomConstraint?.update(inset: kbHeight)
        }
        
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

// MARK: SendAlgosViewDelegate

extension ReceiveAlgosViewController: ReceiveAlgosViewDelegate {
    
    func receiveAlgosViewDidTapAccountSelectionView(_ receiveAlgosView: ReceiveAlgosView) {
        presentAccountList()
    }
    
    func receiveAlgosViewDidTapPreviewButton(_ receiveAlgosView: ReceiveAlgosView) {
        open(.receiveAlgosPreview, by: .push)
    }
}

// MARK: AccountListViewControllerDelegate

extension ReceiveAlgosViewController: AccountListViewControllerDelegate {
    
    func accountListViewControllerDidTapAddButton(_ viewController: AccountListViewController) {
    }
    
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        receiveAlgosView.accountSelectionView.inputTextField.text = account.name
        
        selectedAccount = account
    }
}
