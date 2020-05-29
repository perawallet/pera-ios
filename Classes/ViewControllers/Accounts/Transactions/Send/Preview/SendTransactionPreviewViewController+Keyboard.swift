//
//  SendTransactionPreviewViewController+Keyboard.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

extension SendTransactionPreviewViewController {
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
        
        let kbHeight = notification.keyboardHeight ?? view.safeAreaBottom
        keyboard.height = kbHeight
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        if sendTransactionPreviewView.noteInputView.frame.maxY > UIScreen.main.bounds.height - kbHeight - 58.0 {
            scrollView.contentInset.bottom = kbHeight
        } else {
            contentViewBottomConstraint?.update(inset: kbHeight)
            scrollView.setContentOffset(CGPoint(x: 0.0, y: view.safeAreaBottom), animated: true)
        }
        
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

extension SendTransactionPreviewViewController: TouchDetectingScrollViewDelegate {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if sendTransactionPreviewView.previewButton.frame.contains(point) ||
            sendTransactionPreviewView.amountInputView.frame.contains(point) ||
            sendTransactionPreviewView.transactionReceiverView.frame.contains(point) ||
            sendTransactionPreviewView.noteInputView.frame.contains(point) {
            return
        }
        contentView.endEditing(true)
    }
}
