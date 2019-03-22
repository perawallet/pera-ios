//
//  BaseView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BaseView: UIView {
    
    // MARK: Initialization

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureAppearance()
        prepareLayout()
        linkInteractors()
        setListeners()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAppearance() {
        backgroundColor = rgb(0.97, 0.97, 0.98)
    }
    
    func prepareLayout() {
    }
    
    func linkInteractors() {
    }
    
    func setListeners() {
    }
}
