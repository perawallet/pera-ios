//
//  String+Attributes.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension String {
    
    enum Attribute {
        case textColor(UIColor)
        case font(UIFont)
        case letterSpacing(CGFloat)
        case lineSpacing(CGFloat)
    }
    
    func attributed(_ attributes: [Attribute] = []) -> NSAttributedString {
        var theAttributes: [NSAttributedString.Key: Any] = [:]
        
        for attr in attributes {
            switch attr {
            case .textColor(let color):
                theAttributes[.foregroundColor] = color
            case .font(let font):
                theAttributes[.font] = font
            case .letterSpacing(let spacing):
                theAttributes[.kern] = spacing
            case .lineSpacing(let spacing):
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = spacing
                theAttributes[.paragraphStyle] = paragraphStyle
            }
        }
        
        return NSAttributedString(string: self, attributes: theAttributes)
    }
    
    // MARK: - Size
    func width(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func height(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func size(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}
