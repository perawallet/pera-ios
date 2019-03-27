//
//  ModalPresentable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

protocol ModalPresentable {
    
    func beforeAnimatedTransition()
    func alongsideAnimatedTransition()
    func afterAnimatedTransition()
}

extension ModalPresentable {
    
    func beforeAnimatedTransition() {
    }
    
    func alongsideAnimatedTransition() {
    }
    
    func afterAnimatedTransition() {
    }
}
