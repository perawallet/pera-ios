//
//  Screen.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum Screen {
    case introduction
    case welcome
    case choosePassword(ChoosePasswordViewController.Mode)
    case localAuthenticationPreference
}

extension Screen {
    
    enum Transition {
    }
}

extension Screen.Transition {
    
    enum Open: Equatable {
        case push
        case present
        case customPresent(
            presentationStyle: UIModalPresentationStyle?,
            transitionStyle: UIModalTransitionStyle?,
            transitioningDelegate: UIViewControllerTransitioningDelegate?)
        
        static func == (lhs: Open, rhs: Open) -> Bool {
            switch (lhs, rhs) {
            case (.push, .push):
                return true
            case (.present, .present):
                return true
            case (.customPresent, .customPresent):
                return false
            default:
                return false
            }
        }
    }
    
    enum Close {
        case pop
        case dismiss
    }
}
