//
//  ChoosePasswordViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ChoosePasswordViewModel {
    
    private let mode: ChoosePasswordViewController.Mode
    
    private var password = ""
    
    private var isPasswordValid: Bool {
        return password.count == 6
    }
    
    init(mode: ChoosePasswordViewController.Mode) {
        self.mode = mode
    }
    
    func configure(_ choosePasswordView: ChoosePasswordView) {
        switch mode {
        case .setup:
            choosePasswordView.titleLabel.text = "password-set-subtitle".localized
        case .verify:
            choosePasswordView.titleLabel.text = "password-verify-subtitle".localized
        case .login:
            choosePasswordView.titleLabel.text = "login-subtitle".localized
        case .resetPassword:
            choosePasswordView.titleLabel.text = "password-change-subtitle".localized
        case .resetVerify:
            choosePasswordView.titleLabel.text = "password-verify-subtitle".localized
        case .confirm:
            choosePasswordView.titleLabel.text = "login-subtitle".localized
        }
    }
    
    func configureSelection(in choosePasswordView: ChoosePasswordView, for value: NumpadKey, then handler: (String) -> Void) {
        switch value {
        case let .number(number):
            if isPasswordValid {
                handler(password)
                return
            }
            
            password.append(number)
        case .delete:
            if !password.isEmpty {
                password.removeLast()
            }
        case .spacing:
            break
        }
        
        if isPasswordValid {
            update(in: choosePasswordView, for: value)
            handler(password)
            return
        }
        
        update(in: choosePasswordView, for: value)
    }
    
    func update(in choosePasswordView: ChoosePasswordView, for value: NumpadKey) {
        switch value {
        case .number:
            let passwordInputCircleView = choosePasswordView.passwordInputView.passwordInputCircleViews[password.count - 1]
            
            if passwordInputCircleView.state == .error {
                for view in choosePasswordView.passwordInputView.passwordInputCircleViews {
                    view.state = .empty
                }
            }
            
            passwordInputCircleView.state = .filled
        case .delete:
            if isPasswordValid {
                let passwordInputCircleView = choosePasswordView.passwordInputView.passwordInputCircleViews[password.count - 1]
                passwordInputCircleView.state = .empty
                return
            }
            
            let passwordInputCircleView = choosePasswordView.passwordInputView.passwordInputCircleViews[password.count]
            
            if passwordInputCircleView.state == .error {
                return
            }
            
            passwordInputCircleView.state = .empty
            return
        case .spacing:
            break
        }
    }
    
    func reset(_ choosePasswordView: ChoosePasswordView) {
        password = ""
        
        for view in choosePasswordView.passwordInputView.passwordInputCircleViews {
            view.state = .empty
        }
    }
    
    func displayWrongPasswordState(_ choosePasswordView: ChoosePasswordView) {
        password = ""
        
        for view in choosePasswordView.passwordInputView.passwordInputCircleViews {
            view.state = .error
        }
    }
}
