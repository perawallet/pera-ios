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
        
        tintColor = SharedColors.softGray
        backgroundColor = SharedColors.softGray
        layer.cornerRadius = 16
        onTintColor = SharedColors.purple
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
