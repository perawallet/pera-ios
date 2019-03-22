//
//  IntroductionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class IntroductionViewController: BaseScrollViewController {
    
    // MARK: Components

    private lazy var introductionView: IntroductionView = {
        let view = IntroductionView()
        return view
    }()
    
    // MARK: Setup
    
    override func prepareLayout() {
        super.prepareLayout()
        
        shouldIgnoreBottomLayoutGuide = false
        
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
        open(.welcome, by: .push)
    }
    
    func introductionViewDidTapRecoverButton(_ introductionView: IntroductionView) {
        open(.accountRecover, by: .push)
    }
}
