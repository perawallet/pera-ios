//
//  MainButton.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class MainButton: UIButton {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let size = CGSize(width: 285.0, height: 56.0)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    override var intrinsicContentSize: CGSize {
        return layout.current.size
    }
    
    // MARK: Initialization

    init(title: String? = nil) {
        super.init(frame: .zero)
        
        configureButton()
        
        setTitle(title, for: .normal)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configuration
    
    private func configureButton() {
        titleLabel?.textAlignment = .center
        setBackgroundImage(img("bg-main-button"), for: .normal)
        setTitleColor(SharedColors.black, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
    }
}
