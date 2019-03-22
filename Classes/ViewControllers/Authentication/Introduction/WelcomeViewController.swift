//
//  WelcomeViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseScrollViewController {

    // MARK: Components
    
    private lazy var welcomeView: WelcomeView = {
        let view = WelcomeView()
        return view
    }()
    
    // MARK: Setup
    
    override func prepareLayout() {
        super.prepareLayout()
        
        shouldIgnoreBottomLayoutGuide = false
        
        setupWelcomeViewLayout()
    }
    
    private func setupWelcomeViewLayout() {
        contentView.addSubview(welcomeView)
        
        welcomeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func linkInteractors() {
        welcomeView.delegate = self
    }
}

// MARK: WelcomeViewDelegate

extension WelcomeViewController: WelcomeViewDelegate {
    
    func welcomeViewDidTapDoneButton(_ introductionView: WelcomeView) {
        open(.choosePassword(.setup), by: .push)
    }
}
