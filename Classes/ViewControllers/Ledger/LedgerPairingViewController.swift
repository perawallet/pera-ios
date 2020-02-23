//
//  LedgerPairingViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import SnapKit

class LedgerPairingViewController: BaseScrollViewController {
    
    private lazy var ledgerPairingView = LedgerPairingView()
    
    private var keyboard = Keyboard()
    private var contentViewBottomConstraint: Constraint?
    
    private let address: String
    
    init(address: String, configuration: ViewControllerConfiguration) {
        self.address = address
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "ledger-pairing-name-title".localized
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
