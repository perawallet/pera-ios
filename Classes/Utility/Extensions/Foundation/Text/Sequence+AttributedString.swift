//
//  Sequence+AttributedString.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
