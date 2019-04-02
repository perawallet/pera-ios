//
//  IntroductionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class IntroductionViewController: BaseScrollViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    // MARK: Components

    private lazy var introductionView: IntroductionView = {
        let view = IntroductionView()
        return view
    }()
    
    var mode: AccountSetupMode = .initialize
    
    // MARK: Setup
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupIntroducitionViewLayout()
    }
    
    private func setupIntroducitionViewLayout() {
        contentView.addSubview(introductionView)
        
        introductionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func linkInteractors() {
        introductionView.delegate = self
    }
}

// MARK: IntroductionViewDelegate

extension IntroductionViewController: IntroductionViewDelegate {
    
    func introductionViewDidTapCreateAccountButton(_ introductionView: IntroductionView) {
        switch mode {
        case .initialize:
            open(.welcome, by: .push)
        case .new:
            open(.accountNameSetup(mode: mode), by: .push)
        }
    }
    
    func introductionViewDidTapRecoverButton(_ introductionView: IntroductionView) {
        open(.accountRecover(mode: mode), by: .push)
    }
}
