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
        return CGSize(width: 20.0, height: 20.0)
    }
    
    var state: State = .empty {
        didSet {
            switch state {
            case .empty:
                image = img("gray-button-border")
            case .error:
                image = img("gray-button-border", isTemplate: true)
                tintColor = Colors.General.error
            case .filled:
                image = img("green-button-filled")
            }
        }
    }
    
    init() {
        super.init(image: img("gray-button-border"))
        layer.cornerRadius = 10.0
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
