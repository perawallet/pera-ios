//
//  Sequence+AttributedString.swift

import Foundation

extension Sequence where Element: NSAttributedString {
    
    func join(with separator: NSAttributedString) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        for (index, string) in enumerated() {
            if index > 0 {
                attributedString.append(separator)
            }
            
            attributedString.append(string)
        }
        
        return attributedString
    }
}
