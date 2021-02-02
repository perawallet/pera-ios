//
//  InputViewDelegate.swift

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
