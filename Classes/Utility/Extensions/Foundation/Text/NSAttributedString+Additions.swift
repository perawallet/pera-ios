//
//  NSAttributedString+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension NSAttributedString {
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let compoundAttributedString = NSMutableAttributedString()
        
        compoundAttributedString.append(lhs)
        compoundAttributedString.append(rhs)
        
        return compoundAttributedString
    }
}
