//
//  UIEdgeInsets+Additions.swift

import UIKit

extension UIEdgeInsets {
    
    var horizontal: CGFloat {
        return right + left
    }
    
    var vertical: CGFloat {
        return top + bottom
    }
}
