//
//  UIImage+Size.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UIImage {
    
    func convert(to targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        var editedSize: CGSize
        
        if widthRatio > heightRatio {
            editedSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            editedSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: editedSize.width, height: editedSize.height)
        
        UIGraphicsBeginImageContextWithOptions(editedSize, false, 0.0)
        draw(in: rect)
        
        let editedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return editedImage
    }
}
