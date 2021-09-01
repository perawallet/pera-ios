// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension UITextField {
    public func shiftCaretToStart() {
        shiftCaretTo(position: beginningOfDocument)
    }

    public func shiftCaretToEnd() {
        shiftCaretTo(position: endOfDocument)
    }

    public func shiftCaretToPositionFromStart(byOffset offset: Int) {
        if let newPosition = position(from: beginningOfDocument, offset: offset) {
            shiftCaretTo(position: newPosition)
        }
    }

    public func shiftCaretTo(position: UITextPosition) {
        selectedTextRange = textRange(from: position, to: position)
    }
}
