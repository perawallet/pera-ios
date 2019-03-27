//
//  ModalConfiguration.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

struct ModalConfiguration {
    
    let animationMode: AnimationMode
    let dismissMode: DismissMode
    
    init(animationMode: AnimationMode, dismissMode: DismissMode = .none) {
        self.animationMode = animationMode
        self.dismissMode = dismissMode
    }
}

extension ModalConfiguration {
    
    enum AnimationMode {
        case normal(duration: TimeInterval)
        case spring(duration: TimeInterval, damping: CGFloat, velocity: CGFloat)
    }
    
    enum DismissMode {
        case none
        case backgroundTouch
    }
}

extension ModalConfiguration.AnimationMode {
    
    typealias BeforeAnimationHandler = () -> Void
    typealias AnimationHandler = () -> Void
    typealias AfterAnimationHandler = (Bool) -> Void
    
    func animate(
        _ animations: @escaping AnimationHandler,
        before beforeAnimationsHandler: BeforeAnimationHandler? = nil,
        after afterAnimationsHandler: AfterAnimationHandler? = nil
    ) {
        beforeAnimationsHandler?()
        
        switch self {
        case .normal(let duration):
            UIView.animate(
                withDuration: duration,
                animations: {
                    animations()
                },
                completion: { isCompleted in
                    afterAnimationsHandler?(isCompleted)
                }
            )
        case .spring(let duration, let damping, let velocity):
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                usingSpringWithDamping: damping,
                initialSpringVelocity: velocity,
                options: [],
                animations: {
                    animations()
                },
                completion: { isCompleted in
                    afterAnimationsHandler?(isCompleted)
                }
            )
        }
    }
}

extension ModalConfiguration.DismissMode {
    
    var isCancelled: Bool {
        return self == .none
    }
}
