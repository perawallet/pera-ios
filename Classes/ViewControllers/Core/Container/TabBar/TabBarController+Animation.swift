//
//  TabBarController+Animation.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

extension TabBarController {
    func presentTransactionFlow() {
        addTransactionButtons()
        animateCenterButtonAsSelected(true)
        animateSendButton()
        animateRequestButton()
    }
    
    func hideTransactionFlow() {
        animateCenterButtonAsSelected(false)
        hideSendButton()
        hideRequestButton()
    }
    
    private func animateCenterButtonAsSelected(_ isSelected: Bool) {
        let centerBarButton = tabBar.barButtons[2].contentView
        let icon = isSelected ? items[2].barButtonItem.selectedIcon : items[2].barButtonItem.icon
        
        UIView.transition(
            with: centerBarButton,
            duration: 0.15,
            options: .transitionCrossDissolve,
            animations: {
                centerBarButton.setImage(icon, for: .normal)
                centerBarButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.0,
                    usingSpringWithDamping: 0.4,
                    initialSpringVelocity: 0.2,
                    options: [.allowUserInteraction, .curveEaseOut],
                    animations: {
                        centerBarButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    },
                    completion: nil
                )
            }
        )
    }
    
    private func addTransactionButtons() {
        view.addSubview(sendButton)
        sendButton.frame = CGRect(x: view.frame.width / 2.0, y: tabBar.frame.minY + 5.0, width: 0.0, height: 0.0)
        
        view.addSubview(receiveButton)
        receiveButton.frame = CGRect(x: view.frame.width / 2.0, y: tabBar.frame.minY + 5.0, width: 0.0, height: 0.0)
        
        view.layoutIfNeeded()
    }
    
    private func animateSendButton() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: [.allowUserInteraction, .curveEaseIn],
            animations: {
                self.sendButton.frame.origin.x -= 61.0
                self.sendButton.frame.origin.y -= 48.0
                self.sendButton.frame.size = CGSize(width: 48.0, height: 48.0)
            },
            completion: nil
        )
    }
    
    private func hideSendButton() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIView.AnimationOptions.allowUserInteraction,
            animations: {
                self.sendButton.frame.origin.x += 61.0
                self.sendButton.frame.origin.y += 48.0
                self.sendButton.frame.size = CGSize(width: 10.0, height: 10.0)
            },
            completion: { _ in
                self.sendButton.removeFromSuperview()
            }
        )
    }
    
    private func animateRequestButton() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.08,
            options: [.allowUserInteraction, .curveEaseInOut],
            animations: {
                self.receiveButton.frame.origin.x += 12.0
                self.receiveButton.frame.origin.y -= 48.0
                self.receiveButton.frame.size = CGSize(width: 48.0, height: 48.0)
            },
            completion: nil
        )
    }
    
    private func hideRequestButton() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.08,
            options: UIView.AnimationOptions.allowUserInteraction,
            animations: {
                self.receiveButton.frame.origin.x -= 12.0
                self.receiveButton.frame.origin.y += 48.0
                self.receiveButton.frame.size = CGSize(width: 10.0, height: 10.0)
            },
            completion: { _ in
                self.receiveButton.removeFromSuperview()
            }
        )
    }
}
