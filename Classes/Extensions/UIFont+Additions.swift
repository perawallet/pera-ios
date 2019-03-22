//
//  UIFont+Additions.swift
//  algorand
//
//  Created by Omer Emre Aslan on 22.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum Font: String {
    case montserrat = "Montserrat"
    case opensans = "OpenSans"
}

enum FontWeight {
    case bold(size: CGFloat)
    case boldItalic(size: CGFloat)
    case italic(size: CGFloat)
    case regular(size: CGFloat)
    case semiBold(size: CGFloat)
}

extension UIFont {
    static func font(_ font: Font, withWeight weight: FontWeight) -> UIFont {
        let fontName = self.fontName(font, withWeight: weight)
        
        switch weight {
        case .bold(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.boldSystemFont(ofSize: size)
        case .boldItalic(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size).boldItalic
        case .italic(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.italicSystemFont(ofSize: size)
        case .regular(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
        case .semiBold(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    private static func fontName(_ font: Font,
                                 withWeight weight: FontWeight) -> String {
        let fontName = "\(font.rawValue)-"
        
        switch weight {
        case .bold:
            return fontName.appending("Bold")
        case .boldItalic:
            return fontName.appending("BoldItalic")
        case .italic:
            return fontName.appending("Italic")
        case .regular:
            return fontName.appending("Regular")
        case .semiBold:
            return fontName.appending("SemiBold")
        }
    }
}

extension UIFont {
    var bold: UIFont {
        return font(withTraits: .traitBold)
    }
    
    var italic: UIFont {
        return font(withTraits: .traitItalic)
    }
    
    var boldItalic: UIFont {
        return font(withTraits: [.traitBold, .traitItalic])
    }
    
    func font(withTraits traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        
        return UIFont(descriptor: descriptor, size: 0)
    }
}
