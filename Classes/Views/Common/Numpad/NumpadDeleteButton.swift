//
//  NumpadDeleteButton.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NumpadDeleteButton: UIButton, NumpadTypeable {
    
    override var intrinsicContentSize: CGSize {
        return layout.current.size
    }
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let size = CGSize(width: 30.0, height: 36.0)
    }
    
    private let layout = Layout<LayoutConstants>()

    var value: NumpadValue = .delete
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isEnabled = false
        
        setImage(img("icon-delete-number"), for: .normal)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
