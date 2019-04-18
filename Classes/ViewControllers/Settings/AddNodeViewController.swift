//
//  AddNodeViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

class AddNodeViewController: BaseScrollViewController {
    
    // MARK: Components
    
    private lazy var addNodeView = AddNodeView()
    
    private var contentViewBottomConstraint: Constraint?
    
    private var keyboard = Keyboard()
    
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
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "add-node-title".localized
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        scrollView.touchDetectingDelegate = self
        addNodeView.testButton.addTarget(self, action: #selector(tap(test:)), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contentView.addSubview(addNodeView)
        
        addNodeView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(view.safeAreaBottom).constraint
        }
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
        
        if addNodeView.tokenInputView.frame.maxY > UIScreen.main.bounds.height - kbHeight - 76.0 {
            scrollView.contentInset.bottom = kbHeight
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
        
        scrollView.contentInset.bottom = 0.0
        
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
    
    @objc
    fileprivate func tap(test button: MainButton) {
        view.endEditing(true)
        
        guard let name = addNodeView.nameInputView.inputTextField.text, !name.isEmpty,
            let address = addNodeView.addressInputView.inputTextField.text, !address.isEmpty,
            let token = addNodeView.tokenInputView.inputTextField.text, !token.isEmpty else {
                displaySimpleAlertWith(title: "title-error".localized,
                                       message: "node-settings-text-validation-empty-error".localized)
                return
        }
        
        let testDraft = NodeTestDraft(address: address, token: token)
        
        let predicate = NSPredicate(format: "address = %@", address)
        
        if Node.hasResult(entity: Node.entityName, with: predicate) {
            displaySimpleAlertWith(title: "title-error".localized, message: "node-settings-has-same-result".localized)
            return
        }
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        api?.checkHealth(with: testDraft) { isValidated in
            SVProgressHUD.dismiss()
            
            if isValidated {
                Node.create(entity: Node.entityName, with: [Node.DBKeys.name.rawValue: name,
                                                            Node.DBKeys.address.rawValue: address,
                                                            Node.DBKeys.token.rawValue: token,
                                                            Node.DBKeys.creationDate.rawValue: Date()])
                
                self.popScreen()
            } else {
                self.displaySimpleAlertWith(title: "title-error".localized, message: "node-settings-text-validation-health-error".localized)
            }
        }
    }
}

// MARK: TouchDetectingScrollViewDelegate

extension AddNodeViewController: TouchDetectingScrollViewDelegate {
    
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if addNodeView.testButton.frame.contains(point) {
            return
        }
        
        contentView.endEditing(true)
    }
}
