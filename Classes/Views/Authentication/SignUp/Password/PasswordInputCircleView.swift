//
//  PasswordInputCircle.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PasswordInputCircleView: UIImageView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 40.0, height: 40.0)
    }
    
    var state: State = .empty {
        didSet {
            switch state {
            case .empty:
                image = img("green-button-border", isTemplate: true)
                tintColor = SharedColors.purple
            case .error:
                image = img("green-button-border", isTemplate: true)
                tintColor = UIColor.red
            case .filled:
                image = img("purple-button-filled")
            }
        }
    }
    
    init() {
        super.init(image: img("green-button-border", isTemplate: true))
        
        tintColor = SharedColors.purple
        
        layer.cornerRadius = 20.0
        
        contentMode = .center
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PasswordInputCircleView {
    
    enum State {
        case empty
        case filled
        case error
    }
}
