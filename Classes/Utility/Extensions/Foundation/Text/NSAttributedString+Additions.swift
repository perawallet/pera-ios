//
//  NSAttributedString+Additions.swift

import Foundation

extension NSAttributedString {
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let compoundAttributedString = NSMutableAttributedString()
        
        compoundAttributedString.append(lhs)
        compoundAttributedString.append(rhs)
        
        return compoundAttributedString
    }
}
