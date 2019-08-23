//
//  MainButton.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class MainButton: UIButton {
    
    enum Constants {
        static let horizontalInset: CGFloat = 24.0
    }
    
    // MARK: Initialization

    init(title: String? = nil) {
        super.init(frame: .zero)
        
        configureButton()
        setAttributedTitle(title?.attributed([.letterSpacing(1.20), .textColor(.white)]), for: .normal)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configuration
    
    private func configureButton() {
        titleLabel?.textAlignment = .center
        setBackgroundImage(img("bg-main-button"), for: .normal)
        titleLabel?.font = UIFont.font(.avenir, withWeight: .demiBold(size: 12.0))
    }
}
