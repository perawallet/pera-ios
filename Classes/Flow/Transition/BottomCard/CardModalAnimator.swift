//
//  CardModalAnimator.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class CardModalAnimator: AnimatorObjectType {
    
    var config: Configuration
    
    required init(config: Configuration) {
        self.config = config
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch config.animationMode {
        case .normal(let duration), .spring(let duration, _, _):
            return duration
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if transitionContext.isPresenting {
            if let toView = transitionContext.toView {
                containerView.addSubview(toView)
            }
        }
        
        let animatingView = transitionContext.animatedView
        let animatingViewController = transitionContext.animatedPresentableViewController
        
        let finalFrame = transitionContext.finalFrame
        
        var initialFrame = finalFrame
        initialFrame.origin.y = containerView.frame.height + finalFrame.height
        
        config.animationMode.animate({
            animatingView?.frame = transitionContext.isPresenting ? finalFrame : initialFrame
            animatingViewController?.alongsideAnimatedTransition()
        },
        before: {
            animatingView?.frame = transitionContext.isPresenting ? initialFrame : finalFrame
            animatingViewController?.beforeAnimatedTransition()
        },
        after: { _ in
            animatingViewController?.afterAnimatedTransition()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
