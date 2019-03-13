//
//  AdaptiveLayoutConstants.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum LayoutOrientation {
    
    case undefined
    case portrait
    case landscape
}

protocol AdaptiveLayoutConstants {
    
    static var unknownConstant: CGFloat { get }
    
    static var neutralConstant: CGFloat { get }
    
    init()
    
    mutating func prepareForPhone(orientation: LayoutOrientation)
    
    mutating func prepareForPad(orientation: LayoutOrientation)
}

extension AdaptiveLayoutConstants {
    
    static var unknownConstant: CGFloat { // Constants to be updated for all devices.
        return CGFloat.greatestFiniteMagnitude // It will break layout system.
    }
    
    static var neutralConstant: CGFloat { // Constants not to needed for all devices.
        return 0.0
    }
    
    init() {
        self.init()
    }
    
    mutating func prepareForPhone(orientation: LayoutOrientation) {
    }
    
    mutating func prepareForPad(orientation: LayoutOrientation) {
    }
}
