//
//  Notification+Keyboard.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension Notification {
    
    var keyboardBeginFrame: CGRect? {
        return userInfo?[UIResponder.keyboardFrameBeginUserInfoKey].flatMap { ($0 as? NSValue)?.cgRectValue } ?? nil
    }
    
    var keyboardEndFrame: CGRect? {
        return userInfo?[UIResponder.keyboardFrameEndUserInfoKey].flatMap { ($0 as? NSValue)?.cgRectValue } ?? nil
    }
    
    var keyboardHeight: CGFloat? {
        return keyboardEndFrame?.height
    }
    
    var keyboardAnimationDuration: TimeInterval {
        return userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey].flatMap { $0 as? TimeInterval } ?? 0.25    }
    
    var keyboardAnimationCurve: UIView.AnimationCurve {
        guard let animationCurveRaw = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else {
            return .linear
        }
        
        return UIView.AnimationCurve(rawValue: animationCurveRaw) ?? .linear
    }
}
