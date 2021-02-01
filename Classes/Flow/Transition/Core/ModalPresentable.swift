//
//  ModalPresentable.swift

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
