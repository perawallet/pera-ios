//
//  InputViewDelegate.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

protocol InputViewDelegate: NSObjectProtocol {
    func inputViewDidBeginEditing(inputView: BaseInputView)
    func inputViewDidChangeValue(inputView: BaseInputView)
    func inputViewDidEndEditing(inputView: BaseInputView)
    func inputViewDidReturn(inputView: BaseInputView)
    func inputViewDidTapAccessoryButton(inputView: BaseInputView)
    func inputViewShouldChangeText(inputView: BaseInputView, with text: String) -> Bool
}

extension InputViewDelegate {
    func inputViewDidBeginEditing(inputView: BaseInputView) {
    }
    
    func inputViewDidChangeValue(inputView: BaseInputView) {
    }
    
    func inputViewDidEndEditing(inputView: BaseInputView) {
    }
    
    func inputViewDidReturn(inputView: BaseInputView) {
    }
    
    func inputViewDidTapAccessoryButton(inputView: BaseInputView) {
    }
    
    func inputViewShouldChangeText(inputView: BaseInputView, with text: String) -> Bool {
        return true
    }
}
