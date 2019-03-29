//
//  CardModalPresentationController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class CardModalPresentationController: UIPresentationController {
    
    private enum Colors {
        static let backgroundColor = rgba(0.04, 0.05, 0.07, 0.6)
    }
    
    typealias Configuration = ModalConfiguration
    
    private(set) var modalSize: ModalSize
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let containerSize = containerBounds.size
        let presentedSize = calculateSizeOfPresentedView(with: containerSize)
        let presentedOrigin = calculateOriginOfPresentedView(with: presentedSize, inParentSize: containerSize)
        
        return CGRect(origin: presentedOrigin, size: presentedSize)
    }
    
    private lazy var chromeView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = Colors.backgroundColor
        return view
    }()
    
    private var containerBounds: CGRect {
        return containerView?.bounds ?? .zero
    }
    
    private let config: Configuration
    
    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        config: Configuration,
        modalSize: ModalSize
    ) {
        self.config = config
        self.modalSize = modalSize
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        setAppearances()
        linkInteractors()
    }
    
    override func containerViewWillLayoutSubviews() {
        chromeView.frame = containerBounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        chromeView.alpha = 0.0
        chromeView.frame = containerBounds
        containerView?.insertSubview(chromeView, at: 0)
        
        let animations = {
            self.chromeView.alpha = 1.0
        }
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            animations()
            return
        }
        
        coordinator.animate(
            alongsideTransition: { _ in
                animations()
            },
            completion: nil
        )
    }
    
    override func dismissalTransitionWillBegin() {
        let animations = {
            self.chromeView.alpha = 0.0
        }
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            animations()
            return
        }
        
        coordinator.animate(
            alongsideTransition: { _ in
                animations()
            },
            completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if !completed {
            return
        }
        
        chromeView.removeFromSuperview()
    }
    
    override func size(
        forChildContentContainer container: UIContentContainer,
        withParentContainerSize parentSize: CGSize
    ) -> CGSize {
        return calculateSizeOfPresentedView(with: parentSize)
    }
    
    private func setAppearances() {
        presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView?.layer.cornerRadius = 16.0
        presentedView?.layer.masksToBounds = true
    }
    
    private func linkInteractors() {
        chromeView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(dismissWhenBackgroundTapped(_:)))
        )
    }
    
    @objc
    private func dismissWhenBackgroundTapped(_ recognizer: UITapGestureRecognizer) {
        if config.dismissMode.isCancelled {
            return
        }
        presentedView?.endEditing(true)
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

extension CardModalPresentationController {
    
    func calculateOriginOfPresentedView(with size: CGSize, inParentSize parentSize: CGSize) -> CGPoint {
        switch modalSize {
        case .compressed, .expanded, .half, .custom:
            return CGPoint(x: (parentSize.width - size.width) / 2.0, y: parentSize.height - size.height)
        case .full:
            return CGPoint(x: 0.0, y: 0.0)
        }
    }
    
    func calculateSizeOfPresentedView(with parentSize: CGSize) -> CGSize {
        switch modalSize {
        case .compressed, .expanded:
            let targetSize = modalSize == .compressed ? UIView.layoutFittingCompressedSize : UIView.layoutFittingExpandedSize
            
            guard
                let presentedNavigationController = presentedViewController as? UINavigationController,
                let visiblePresentedViewController = presentedNavigationController.viewControllers.last
                else {
                    return presentedView?.systemLayoutSizeFitting(targetSize) ?? parentSize
            }
            
            let height = visiblePresentedViewController.view.systemLayoutSizeFitting(targetSize).height
            return CGSize(width: parentSize.width, height: height)
        case .half:
            var presentedSize = parentSize
            presentedSize.height = (parentSize.height / 2.0).upper
            return presentedSize
        case .full:
            return parentSize
        case .custom(let size):
            let width = size.width == UIView.noIntrinsicMetric ? parentSize.width : size.width
            let height = size.height == UIView.noIntrinsicMetric ? parentSize.height : size.height
            
            return CGSize(width: width, height: height)
        }
    }
}

extension CardModalPresentationController: ModalPresenterInteractable {
    
    func changeModalSize(to newModalSize: ModalSize, animated: Bool, then completion: (() -> Void)?) {
        
        if modalSize == newModalSize {
            completion?()
            return
        }
        
        modalSize = newModalSize
        
        let newPresentedFrame = frameOfPresentedViewInContainerView
        
        if !animated {
            self.presentedView?.frame = newPresentedFrame
            completion?()
            return
        }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: [],
            animations: {
                self.presentedView?.frame = newPresentedFrame
            },
            completion: { _ in
                completion?()
            }
        )
    }
    
    func changeModalSize(to newModalSize: ModalSize, animated: Bool) {
        changeModalSize(to: newModalSize, animated: animated, then: nil)
    }
}
