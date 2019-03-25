//
//  UIEdgeInsets+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    
    var horizontal: CGFloat {
        return right + left
    }
    
    var vertical: CGFloat {
        return top + bottom
    }
}
