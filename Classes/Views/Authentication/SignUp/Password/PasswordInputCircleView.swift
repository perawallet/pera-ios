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
            if state == .empty {
                image = img("green-button-border")
            } else {
                image = img("green-button-filled")
            }
        }
    }
    
    init() {
        super.init(image: img("green-button-border"))
        
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
    }
}
