//
//  UIFont+Additions.swift
//  algorand
//
//  Created by Omer Emre Aslan on 22.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum FontType: String {
    case avenir = "AvenirNext"
    case overpass = "Overpass"
}

enum FontWeight {
    case regular(size: CGFloat)
    case medium(size: CGFloat)
    case demiBold(size: CGFloat)
    case semiBold(size: CGFloat)
    case bold(size: CGFloat)
    case extraBold(size: CGFloat)
}

extension UIFont {
    
    static func font(_ font: FontType, withWeight weight: FontWeight) -> UIFont {
        let fontName = self.fontName(font, withWeight: weight)
        
        switch weight {
        case .regular(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
        case .medium(size: let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
        case .demiBold(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
        case .semiBold(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
        case .bold(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.boldSystemFont(ofSize: size)
        case .extraBold(let size):
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)

        }
    }
    
    private static func fontName(_ font: FontType, withWeight weight: FontWeight) -> String {
        let fontName = "\(font.rawValue)-"
        
        switch weight {
        case .regular:
            return fontName.appending("Regular")
        case .medium:
            return fontName.appending("Medium")
        case .demiBold:
            return fontName.appending("DemiBold")
        case .semiBold:
            return fontName.appending("SemiBold")
        case .bold:
            return fontName.appending("Bold")
        case .extraBold:
            return fontName.appending("ExtraBold")
        }
    }
}
