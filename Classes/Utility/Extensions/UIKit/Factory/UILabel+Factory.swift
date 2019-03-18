//
//  UILabel+Factory.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UILabel {
    
    func withLine(_ line: Line) -> UILabel {
        switch line {
        case .single:
            numberOfLines = 1
            lineBreakMode = .byTruncatingTail
        case .multi(let line):
            numberOfLines = line
            lineBreakMode = .byWordWrapping
        case .contained:
            numberOfLines = 0
            lineBreakMode = .byWordWrapping
        }
        
        return self
    }
    
    func withFont(_ font: UIFont) -> UILabel {
        self.font = font
        return self
    }
    
    func withTextColor(_ textColor: UIColor) -> UILabel {
        self.textColor = textColor
        return self
    }
    
    func withText(_ text: String) -> UILabel {
        self.text = text
        return self
    }
    
    func withAlignment(_ alignment: NSTextAlignment) -> UILabel {
        self.textAlignment = alignment
        return self
    }
}

extension UILabel {
    
    enum Line {
        case single
        case multi(Int)
        case contained
    }
}
