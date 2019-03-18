//
//  UIButton+Factory.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UIButton {
    
    func withImage(_ image: UIImage?) -> UIButton {
        setImage(image, for: .normal)
        return self
    }
    
    func withBackgroundImage(_ image: UIImage?) -> UIButton {
        setBackgroundImage(image, for: .normal)
        return self
    }
    
    func withFont(_ font: UIFont) -> UIButton {
        titleLabel?.font = font
        return self
    }
    
    func withTitleColor(_ textColor: UIColor) -> UIButton {
        setTitleColor(textColor, for: .normal)
        return self
    }
    
    func withTitle(_ text: String) -> UIButton {
        setTitle(text, for: .normal)
        return self
    }
    
    func withAlignment(_ alignment: NSTextAlignment) -> UIButton {
        titleLabel?.textAlignment = alignment
        return self
    }
}
