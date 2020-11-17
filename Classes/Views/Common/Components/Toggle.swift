//
//  Toggle.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class Toggle: UISwitch {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tintColor = rgba(0.47, 0.47, 0.5, 0.16)
        backgroundColor = rgba(0.47, 0.47, 0.5, 0.16)
        layer.cornerRadius = 16
        onTintColor = Colors.Main.primary600
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
