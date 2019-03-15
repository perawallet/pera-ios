//
//  UIViewController+Flow.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UIViewController {

    func closeScreen(by style: Screen.Transition.Close, animated: Bool = true, onCompletion completion: ScreenTransitionCompletion? = nil) {
        switch style {
        case .pop:
            navigationController?.popViewController(animated: animated)
        case .dismiss:
            presentingViewController?.dismiss(animated: animated, completion: {
                completion?()
            })
        }
    }
    
    func dismissScreen() {
        closeScreen(by: .dismiss)
    }
    
    func popScreen() {
        closeScreen(by: .pop)
    }
}
