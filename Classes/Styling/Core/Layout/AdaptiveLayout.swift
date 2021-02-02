//
//  AdaptiveLayout.swift

import UIKit

protocol AdaptiveLayout {
    
    associatedtype T: AdaptiveLayoutConstants
    
    var current: T { get }
    
    init()
}

extension AdaptiveLayout {
    
    init() {
        self.init()
    }
}

struct Layout<Constants: AdaptiveLayoutConstants> {
    
    typealias T = Constants
    
    private var constants = T()
}

extension Layout: AdaptiveLayout {
    
    var current: T {
        
        var copyConstants = constants
        
        var orientation: LayoutOrientation
        
        if UIApplication.shared.isPortrait {
            orientation = .portrait
        } else if UIApplication.shared.isLandscape {
            orientation = .landscape
        } else {
            orientation = .undefined
        }
        
        if UIApplication.shared.isPad {
            copyConstants.prepareForPad(orientation: orientation)
        } else {
            copyConstants.prepareForPhone(orientation: orientation)
        }
        
        return copyConstants
    }
}
