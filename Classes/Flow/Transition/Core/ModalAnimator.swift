//
//  ModalAnimator.swift

import UIKit

protocol ModalAnimator: UIViewControllerAnimatedTransitioning {
    typealias Configuration = ModalConfiguration
    
    var config: Configuration { get }
    
    init(config: Configuration)
}
