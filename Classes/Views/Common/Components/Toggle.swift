//
//  Toggle.swift

import UIKit

class Toggle: UISwitch {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tintColor = rgba(0.47, 0.47, 0.5, 0.16)
        backgroundColor = rgba(0.47, 0.47, 0.5, 0.16)
        layer.cornerRadius = 16
        onTintColor = Colors.General.selected
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
