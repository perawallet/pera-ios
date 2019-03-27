//
//  ModalAnimator.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ModalAnimator: UIViewControllerAnimatedTransitioning {
    
    typealias Configuration = ModalConfiguration
    
    var config: Configuration { get }
    
    init(config: Configuration)
}
