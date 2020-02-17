//
//  CardModalPresenter.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class CardModalPresenter: ModalPresenterObjectType {
    
    let config: Configuration
    private var initialModalSize: ModalSize
    
    required init(config: Configuration, initialModalSize: ModalSize = .half) {
        self.config = config
        self.initialModalSize = initialModalSize
        super.init()
    }
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
            return CardModalAnimator(config: config)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardModalAnimator(config: config)
    }
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
            return CardModalPresentationController(
                presentedViewController: presented,
                presenting: presenting,
                config: config,
                modalSize: initialModalSize
            )
    }
}
