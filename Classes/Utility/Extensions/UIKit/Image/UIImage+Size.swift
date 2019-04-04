//
//  UIImage+Size.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UIImage {
    
    func convert(to size: CGSize, scale: CGFloat) -> UIImage? {
        let imageFrame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: imageFrame)
        
        let copied = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return copied
    }
}
