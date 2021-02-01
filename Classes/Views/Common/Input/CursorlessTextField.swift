//
//  CursorlessTextField.swift

import UIKit

class CursorlessTextField: UITextField {
    
    weak var cursorlessTextFieldDelegate: CursorlessTextFieldDelegate?
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        cursorlessTextFieldDelegate?.cursorlessTextFieldDidDeleteBackward(self)
    }
}

extension UITextField {
    func setLeftPadding(amount point: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: point, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
    
    func setRightPadding(amount point: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: point, height: frame.size.height))
        rightView = paddingView
        rightViewMode = .always
    }
}

protocol CursorlessTextFieldDelegate: class {
    func cursorlessTextFieldDidDeleteBackward(_ cursorlessTextField: CursorlessTextField)
}
