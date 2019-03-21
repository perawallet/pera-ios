//
//  WelcomeViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseViewController {

    // MARK: Components
    
    private lazy var welcomeView: WelcomeView = {
        let view = WelcomeView()
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = rgb(0.95, 0.96, 0.96)
    }
    
    override func prepareLayout() {
        view.addSubview(welcomeView)
        
        welcomeView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
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
